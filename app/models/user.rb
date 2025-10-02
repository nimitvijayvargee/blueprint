# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  avatar              :string
#  email               :string           not null
#  github_access_token :string
#  github_username     :string
#  is_banned           :boolean          default(FALSE), not null
#  is_mcg              :boolean          default(FALSE), not null
#  last_active         :datetime
#  role                :integer          default("user"), not null
#  timezone            :string
#  username            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  slack_id            :string
#
class User < ApplicationRecord
  has_many :projects
  has_many :journal_entries
  has_many :follows, dependent: :destroy
  has_many :followed_projects, through: :follows, source: :project
  has_one :task_list, dependent: :destroy

  enum :role, { user: 0, admin: 1 }

  validates :role, presence: true
  validates :is_banned, inclusion: { in: [ true, false ] }

  has_paper_trail
  has_recommended :projects

  def self.exchange_slack_token(code, redirect_uri)
    response = Faraday.post("https://slack.com/api/oauth.v2.access",
                            {
                              client_id: ENV.fetch("SLACK_CLIENT_ID", nil),
                              client_secret: ENV.fetch("SLACK_CLIENT_SECRET", nil),
                              redirect_uri: redirect_uri,
                              code: code
                            })

    result = JSON.parse(response.body)

    unless result["ok"]
      Rails.logger.error("Slack OAuth error: #{result['error']}")
      # Honeybadger.notify("Slack OAuth error: #{result['error']}")
      raise StandardError, "Failed to authenticate with Slack: #{result['error']}"
    end

    slack_id = result["authed_user"]["id"]
    user = User.find_by(slack_id: slack_id)
    if user.present?
      Rails.logger.tagged("UserCreation") do
        Rails.logger.info({
          event: "existing_user_found",
          slack_id: slack_id,
          user_id: user.id,
          email: user.email
        }.to_json)
      end

      user.refresh_profile!

      unless AllowedEmail.allowed?(user.email)
        raise StandardError, "You do not have access."
      end

      return user
    end

    user = create_from_slack(slack_id)
    user
  end

  def self.create_from_slack(slack_id)
    user_info = fetch_slack_user_info(slack_id)
    if user_info.user.is_bot
      Rails.logger.warn({
        event: "slack_user_is_bot",
        slack_id: slack_id,
        user_info: user_info.to_h
      }.to_json)
      return nil
    end

    email = user_info.user.profile.email
    username_from_slack = user_info.user.profile.display_name.presence || user_info.user.profile.real_name
    timezone = user_info.user.tz
    avatar = user_info.user.profile.image_192 || user_info.user.profile.image_512

    Rails.logger.tagged("UserCreation") do
      Rails.logger.info({
        event: "slack_user_found",
        slack_id: slack_id,
        email: email,
        username: username_from_slack,
        timezone: timezone,
        avatar: avatar
      }.to_json)
    end

    if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
      Rails.logger.warn({
        event: "slack_user_missing_or_invalid_email",
        slack_id: slack_id,
        email: email,
        user_info: user_info.to_h
      }.to_json)
      # Honeybadger.notify("Slack email missing??", context: {
      #   slack_id: slack_id,
      #   email: email,
      #   user_info: user_info.to_h
      # })
      raise StandardError, "Slack ID #{slack_id} has an invalid email: #{email.inspect}"
    end

    # Check if user with same email already exists (from OTP login)
    existing_user = User.find_by(email: email)
    if existing_user.present?
      Rails.logger.tagged("UserCreation") do
        Rails.logger.info({
          event: "merging_slack_data_into_existing_user",
          existing_user_id: existing_user.id,
          slack_id: slack_id,
          email: email
        }.to_json)
      end

      unless AllowedEmail.allowed?(email)
        raise StandardError, "You do not have access."
      end

      # Merge Slack data into existing user
      existing_user.update!(
        slack_id: slack_id,
        username: username_from_slack.presence || existing_user.display_name,
        timezone: timezone.presence || existing_user.timezone,
        avatar: avatar.presence || existing_user.avatar
      )

      return existing_user
    end

    unless AllowedEmail.allowed?(email)
      raise StandardError, "You do not have access."
    end

    User.create!(
    slack_id: slack_id,
      username: username_from_slack,
      email: email,
      timezone: timezone,
      avatar: avatar,
      is_banned: false
    )
  end

  def self.find_or_create_from_email(email)
    begin
      user_info = fetch_slack_user_info_from_email(email)
    rescue Slack::Web::Api::Errors::UsersNotFound => e
      Rails.logger.warn("Slack user not found for email #{email}: #{e.message}")

      unless AllowedEmail.allowed?(email)
        raise StandardError, "You do not have access."
      end

      user = User.find_or_create_by!(email: email) do |user|
      user.is_banned = false
      user.role = :user
      end
      return user
    end

    if user_info.user.is_bot
      Rails.logger.warn({
        event: "slack_user_is_bot",
        slack_id: slack_id,
        user_info: user_info.to_h
      }.to_json)
      return nil
    end

    slack_id = user_info.user.id
    email = user_info.user.profile.email
    username_from_slack = user_info.user.profile.display_name.presence || user_info.user.profile.real_name
    timezone = user_info.user.tz
    avatar = user_info.user.profile.image_192 || user_info.user.profile.image_512

    unless AllowedEmail.allowed?(email)
      raise StandardError, "You do not have access."
    end

    Rails.logger.tagged("UserCreation") do
      Rails.logger.info({
        event: "slack_user_found",
        slack_id: slack_id,
        email: email,
        username: username_from_slack,
        timezone: timezone,
        avatar: avatar
      }.to_json)
    end

    if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
      Rails.logger.warn({
        event: "slack_user_missing_or_invalid_email",
        slack_id: slack_id,
        email: email,
        user_info: user_info.to_h
      }.to_json)
      # Honeybadger.notify("Slack email missing??", context: {
      #   slack_id: slack_id,
      #   email: email,
      #   user_info: user_info.to_h
      # })
      raise StandardError, "Slack ID #{slack_id} has an invalid email: #{email.inspect}"
    end

    # Check if user with same slack ID already exists
    existing_user = User.find_by(slack_id: slack_id)
    if existing_user.present?
      Rails.logger.tagged("UserCreation") do
        Rails.logger.info({
          event: "slack_user_already_exists",
          existing_user_id: existing_user.id,
          slack_id: slack_id,
          email: email
        }.to_json)
      end

      existing_user.update!(
        slack_id: slack_id,
        username: username_from_slack.presence || existing_user.username,
        timezone: timezone.presence || existing_user.timezone,
        avatar: avatar.presence || existing_user.avatar
      )

      return existing_user
    end

    User.create!(
      slack_id: slack_id,
      username: username_from_slack,
      email: email,
      timezone: timezone,
      avatar: avatar,
      is_banned: false
    )
  end

  def self.fetch_slack_user_info_from_email(email)
    client = Slack::Web::Client.new(token: ENV.fetch("SLACK_BOT_TOKEN", nil))

    r = 0
    begin
      client.users_lookupByEmail(email: email)
    rescue Slack::Web::Api::Errors::TooManyRequestsError => e
      if r < 3
        s = e.retry_after
        Rails.logger.warn("Slack API ratelimit, retry in #{s} count#{r + 1}")
        sleep s
        r += 1
        retry
      else
        Rails.logger.error("Slack API ratelimit, max retries on users_lookupByEmail for #{email}.")
        raise
      end
    end
  end

  def self.fetch_slack_user_info(slack_id)
    client = Slack::Web::Client.new(token: ENV.fetch("SLACK_BOT_TOKEN", nil))

    r = 0
    begin
      client.users_info(user: slack_id)
    rescue Slack::Web::Api::Errors::TooManyRequestsError => e
      if r < 3
        s = e.retry_after
        Rails.logger.warn("Slack API ratelimit, retry in #{s} count#{r + 1}")
        sleep s
        r += 1
        retry
      else
        Rails.logger.error("Slack API ratelimit, max retries on #{slack_id}.")
        # Honeybadger.notify("Slack API ratelimit, max retries on #{slack_id}.")
        raise
      end
    end
  end

  def exchange_github_token(code, redirect_uri)
    response = Faraday.post("https://github.com/login/oauth/access_token",
                            {
                              client_id: ENV.fetch("GITHUB_CLIENT_ID", nil),
                              client_secret: ENV.fetch("GITHUB_CLIENT_SECRET", nil),
                              redirect_uri: redirect_uri,
                              code: code
                            },
                            {
                              "Accept" => "application/json"
                            })

    # if result is not successful
    if response.status != 200
      Rails.logger.error("GitHub OAuth error: #{response.body}")
      raise StandardError, "Failed to authenticate with GitHub: #{response.body}"
    end

    result = JSON.parse(response.body)

    access_token = result["access_token"]
    if access_token.blank?
      Rails.logger.error("GitHub OAuth error: access token is blank")
      raise StandardError, "Failed to authenticate with GitHub: access token is blank"
    end

    update!(github_access_token: access_token)
    refresh_profile!
  end

  def refresh_profile!
    Rails.logger.tagged("ProfileRefresh") do
      Rails.logger.info({
        event: "refreshing_profile_data",
        user_id: id,
        slack_id: slack_id
      }.to_json)
    end

    refresh_github_profile!

    unless slack_user?
      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.info({
          event: "profile_refresh_no_slack",
          user_id: id
        }.to_json)
      end
      return
    end

    user_info = User.fetch_slack_user_info(slack_id)

    new_username = user_info.user.profile.display_name.presence || user_info.user.profile.real_name
    new_email = user_info.user.profile.email
    new_timezone = user_info.user.tz
    new_avatar = user_info.user.profile.image_original.presence || user_info.user.profile.image_512
    new_is_mcg = !!user_info.user.is_restricted

    changes = {}
    changes[:username] = { from: username, to: new_username } if username != new_username
    changes[:email] = { from: email, to: new_email } if email != new_email
    changes[:timezone] = { from: timezone, to: new_timezone } if timezone != new_timezone
    changes[:avatar] = { from: avatar, to: new_avatar } if avatar != new_avatar
    changes[:is_mcg] = { from: is_mcg, to: new_is_mcg } if is_mcg != new_is_mcg

    if changes.any?
      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.info({
          event: "profile_changes_detected",
          user_id: id,
          slack_id: slack_id,
          changes: changes
        }.to_json)
      end

      update!(
        username: new_username,
        email: new_email,
        timezone: new_timezone,
        avatar: new_avatar,
        is_mcg: new_is_mcg
      )

      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.info({
          event: "profile_refresh_success",
          user_id: id,
          slack_id: slack_id
        }.to_json)
      end
    else
      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.debug({
          event: "profile_refresh_no_change",
          user_id: id,
          slack_id: slack_id
        }.to_json)
      end
    end
  rescue StandardError => e
    Rails.logger.tagged("ProfileRefresh") do
      Rails.logger.error({
        event: "profile_refresh_failed",
        user_id: id,
        slack_id: slack_id,
        error: e.message
      }.to_json)
    end

    # Honeybadger.notify(e, context: { user_id: id, slack_id: slack_id })
  end

  def refresh_github_profile!
    unless github_user?
      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.info({
          event: "profile_refresh_no_github",
          user_id: id
        }.to_json)
      end
      return
    end

    response = Faraday.get("https://api.github.com/user", nil, {
      "Authorization" => "Bearer #{github_access_token}",
      "X-GitHub-Api-Version" => "2022-11-28",
      "Accept" => "application/vnd.github+json"
    })

    if response.status == 401
      Rails.logger.tagged("ProfileRefresh") do
        Rails.logger.warn({
          event: "github_token_invalid",
          user_id: id
        }.to_json)
      end
      update!(github_access_token: nil)
      return
    end

    result = JSON.parse(response.body)

    update!(github_username: result["login"]) if result["login"].present?
  end

  def follow(project)
    followed_projects << project unless following?(project)
  end

  def unfollow(project)
    followed_projects.delete(project)
  end

  def following?(project)
    followed_projects.include?(project)
  end

  def slack_user?
    slack_id.present? && !slack_id.blank?
  end

  def github_user?
    github_access_token.present? && !github_access_token.blank?
  end

  def tasks
    task_list || create_task_list!
  end

  def invite_to_slack!
    xoxc = ENV.fetch("SLACK_XOXC", nil)
    xoxd = ENV.fetch("SLACK_XOXD", nil)
    channels = ENV.fetch("SLACK_CHANNELS", "").split(",").map(&:strip).reject(&:blank?)

    payload = {
      token: xoxc,
      email: email,
      invites: [
        {
          email: email,
          type: "restricted",
          mode: "manual"
        }
      ],
      restricted: true,
      channels: channels
    }

    Rails.logger.tagged("SlackInvite") do
      Rails.logger.info({ event: "inviting_user", user_id: id, email: email, channels_count: channels.size }.to_json)
    end

    response = Faraday.post("https://slack.com/api/users.admin.inviteBulk") do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Authorization"] = "Bearer #{xoxc}"
      req.headers["Cookie"] = "d=#{xoxd}"
      req.body = JSON.generate(payload)
    end

    result = JSON.parse(response.body) rescue { "ok" => false, "error" => "invalid_json" }

    unless response.status == 200 && result["ok"] != false && result["invites"]&.first["ok"] != false
      Rails.logger.tagged("SlackInvite") do
        Rails.logger.error({ event: "invite_failed", user_id: id, email: email, status: response.status, body: response.body }.to_json)
      end
      raise StandardError, "Slack invite failed: status=#{response.status} body=#{response.body}"
    end

    Rails.logger.tagged("SlackInvite") do
      Rails.logger.info({ event: "invite_enqueued_followup", user_id: id, email: email, response: result }.to_json)
    end

    SlackInviteFinalizeJob.perform_later(id)

    result
  end

  def finalize_slack_invite!
    begin
      user_info = nil
      retries = 0
      max_retries = 10
      delay = 5
      begin
        user_info = User.fetch_slack_user_info_from_email(email)
      rescue Slack::Web::Api::Errors::UsersNotFound
        if retries < max_retries
          Rails.logger.info("Slack user not found for #{email}, waiting #{delay}s and retrying (#{retries + 1}/#{max_retries})")
          sleep delay
          retries += 1
          retry
        else
          raise
        end
      end
    rescue StandardError => e
      Rails.logger.tagged("SlackInvite") do
        Rails.logger.error({ event: "no_slack_user_after_invite", user_id: id, email: email, error: e.message }.to_json)
      end
      return
    end

    update!(slack_id: user_info.user.id)
    refresh_profile!

    Rails.logger.tagged("SlackInvite") do
      Rails.logger.info({ event: "invite_success", user_id: id, email: email }.to_json)
    end
  end

  def check_github_repo(org, repo_name, project_id: nil)
    puts "Checking GitHub repo #{org}/#{repo_name} for user #{id} (#{github_username})"
    unless github_user?
      Rails.logger.tagged("GitHubFetch") do
        Rails.logger.info({
          event: "fetch_no_github",
          user_id: id
        }.to_json)
      end
      return false
    end

    response = fetch_github("/repos/#{org}/#{repo_name}")

    if response.status == 404 || response.status == 301
      return { ok: false, error: "This repo does not exist, or is private." }
    end

    data = JSON.parse(response.body)

    can_push = data["permissions"]["push"]

    unless can_push
      return { ok: false, error: "You do not have permission to write to this repo." }
    end

    normalized = Project.normalize_repo_link("#{org}/#{repo_name}", github_username)

    # Ensure this repo isn't already linked to another project
    in_use = if project_id.present?
      Project.where(repo_link: normalized).where.not(id: project_id).exists?
    else
      Project.where(repo_link: normalized).exists?
    end

    if in_use
      { ok: false, error: "This repo is already linked to another project" }
    else
      { ok: true, can_push: can_push }
    end
  end

  def fetch_github(path, method: :get, check_token: true, get_all: false, params: {}, data: {}, headers: {})
    unless github_user?
      Rails.logger.tagged("GitHubFetch") do
        Rails.logger.info({
          event: "fetch_no_github",
          user_id: id
        }.to_json)
      end
      raise StandardError, "No GitHub account linked"
    end

    headers = {
      "Authorization" => "Bearer #{github_access_token}",
      "X-GitHub-Api-Version" => "2022-11-28",
      "Accept" => "application/vnd.github+json"
    }.merge(headers)

    base_url = path.start_with?("http") ? path : "https://api.github.com#{path}"

    response = case method
    when :get
      Faraday.get(base_url, params.presence, headers)
    when :post
      url = params.present? ? "#{base_url}?#{params.to_query}" : base_url
      Faraday.post(url, data.to_json, headers)
    when :put
      url = params.present? ? "#{base_url}?#{params.to_query}" : base_url
      Faraday.put(url, data.to_json, headers)
    when :patch
      url = params.present? ? "#{base_url}?#{params.to_query}" : base_url
      Faraday.patch(url, data.to_json, headers)
    when :delete
      url = params.present? ? "#{base_url}?#{params.to_query}" : base_url
      Faraday.delete(url, nil, headers)
    else
      raise ArgumentError, "Unsupported HTTP method: #{method}"
    end

    if check_token && response.status == 401
      Rails.logger.tagged("GitHubFetch") do
        Rails.logger.warn({ event: "fetch_401", user_id: id }.to_json)
      end
      update!(github_access_token: nil)
    end

    response
  end

  def display_name
    if username.present?
      username
    elsif email.present?
      local = email.split("@").first
      if local.blank?
        "User#{id}"
      elsif local.length < 2
        "*"
      else
        "#{local[0]}**#{local[-1]}"
      end
    else
      "User#{id}"
    end
  end

  def tickets
    0
  end

  def follow_project!(project)
    followed_projects << project unless following?(project)
  end

  def unfollow_project!(project)
    followed_projects.destroy(project)
  end

  def avatar_url
    avatar || "https://hc-cdn.hel1.your-objectstorage.com/s/v3/c283ae01214b9052480f1e216e43dbe09a424048_image.png"
  end
end
