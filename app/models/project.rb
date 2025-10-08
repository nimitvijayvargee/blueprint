# == Schema Information
#
# Table name: projects
#
#  id                     :bigint           not null, primary key
#  demo_link              :string
#  description            :text
#  funding_needed_cents   :integer          default(0), not null
#  hackatime_project_keys :string           default([]), is an Array
#  is_deleted             :boolean          default(FALSE)
#  needs_funding          :boolean          default(TRUE)
#  project_type           :string
#  readme_link            :string
#  repo_link              :string
#  review_status          :string
#  tier                   :integer
#  title                  :string
#  views_count            :integer          default(0), not null
#  ysws                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_projects_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Project < ApplicationRecord
  belongs_to :user
  has_many :journal_entries, dependent: :destroy
  has_many :timeline_items, dependent: :destroy
  has_many :follows, dependent: :destroy
  has_many :followers, through: :follows, source: :user
  has_many :design_reviews, dependent: :destroy

  # Enums
  enum :project_type, {
    custom: "custom"
  }

  enum :review_status, {
    awaiting_idv: "awaiting_idv",
    design_pending: "design_pending",
    design_approved: "design_approved",
    design_needs_revision: "design_needs_revision",
    design_rejected: "design_rejected",
    build_pending: "build_pending",
    build_approved: "build_approved",
    build_needs_revision: "build_needs_revision",
    build_rejected: "build_rejected"
  }

  enum :tier, {
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4
  }, prefix: true

  validates :title, presence: true
  validates :description, presence: true
  validates :funding_needed_cents, numericality: { greater_than_or_equal_to: 0 }
  validate :funding_needed_within_tier_max
  has_one_attached :banner

  has_paper_trail
  include PaperTrailHelper

  # Order projects by most recent journal entry; fall back to project creation
  scope :order_by_recent_journal, -> {
    left_joins(:journal_entries)
      .select("projects.*, COALESCE(MAX(journal_entries.created_at), projects.created_at) AS last_activity_at")
      .group("projects.id")
      .order(Arel.sql("last_activity_at DESC"))
  }

  before_validation :normalize_repo_link
  before_validation :set_funding_needed_cents_to_zero_if_no_funding
  after_update_commit :sync_github_jourunal!, if: -> { saved_change_to_repo_link? && repo_link.present? }
  after_update :invalidate_design_reviews_on_resubmit, if: -> { saved_change_to_review_status? && design_pending? }
  after_update :dm_status!, if: -> { saved_change_to_review_status? }

  def self.parse_repo(repo)
    # Supports:
    # - Full URL (http/https): https://github.com/org/repo[.git][/...]
    # - SSH: git@github.com:org/repo[.git]
    # - Bare: org/repo
    # - Repo only: repo (org inferred by caller)
    repo = repo.to_s.strip
    return nil if repo.blank?

    case repo
    when %r{\Ahttps?://github\.com/([^/]+)/([^/]+)}i
      org = Regexp.last_match(1)
      repo_name = Regexp.last_match(2)
    when %r{\Agit@github\.com:([^/]+)/([^/]+)\z}i,
         %r{\Agit@github\.com:([^/]+)/([^/]+)\.git\z}i
      org = Regexp.last_match(1)
      repo_name = Regexp.last_match(2)
    when %r{\Agithub\.com/([^/]+)/([^/]+)}i
      org = Regexp.last_match(1)
      repo_name = Regexp.last_match(2)
    when %r{\A([^/]+)/([^/]+)\z}
      org = Regexp.last_match(1)
      repo_name = Regexp.last_match(2)
    when %r{\A([\w.-]+)\z}
      org = nil
      repo_name = repo
    else
      return nil
    end

    # Strip common suffixes
    repo_name = repo_name.sub(/\.git\z/i, "")

    { org: org, repo_name: repo_name }
  end

  def self.normalize_repo_link(raw, username)
    stripped = raw.to_s.strip
    return if stripped.blank?

    parsed = Project.parse_repo(stripped)
    return unless parsed

    org = parsed[:org] || username
    repo = parsed[:repo_name]

    return if org.blank? || repo.blank?

    "https://github.com/#{org}/#{repo}"
  end

  def generate_timeline
    timeline = []

    timeline << { type: :creation, date: created_at }

    journal_entries.order(created_at: :asc).each do |entry|
      timeline << { type: :journal, date: entry.created_at, entry: entry }
    end

    ship_design_events = attribute_updated_event(object: self, attribute: :review_status, after: "design_pending", all: true)
    user_ids = ship_design_events.map { |e| e[:whodunnit] }.compact.uniq

    negative_reviews = design_reviews.where(result: %w[returned rejected]).order(created_at: :asc)
    return_design_events = []
    reject_design_events = []

    negative_reviews.each do |review|
      event = { type: review.result == "returned" ? :return_design : :reject_design, date: review.created_at, user_id: review.reviewer_id, feedback: review.feedback, tier_override: review.tier_override, grant_override_cents: review.grant_override_cents }
      review.result == "returned" ? return_design_events << event : reject_design_events << event
      user_ids << event[:user_id].to_s
    end

    users = User.where(id: user_ids).index_by { |u| u.id.to_s }

    ship_design_events.each do |event|
      user = users[event[:whodunnit].to_s]
      timeline << { type: :ship_design, date: event[:timestamp], user: user }
    end

    return_design_events.each do |event|
      user = users[event[:user_id].to_s]
      timeline << { type: :return_design, date: event[:date], user: user, feedback: event[:feedback] }
    end

    reject_design_events.each do |event|
      user = users[event[:user_id].to_s]
      timeline << { type: :reject_design, date: event[:date], user: user, feedback: event[:feedback], tier_override: event[:tier_override], grant_override_cents: event[:grant_override_cents] }
    end

    timeline.sort_by { |e| e[:date] }
  end

  def bom_file_url
    return nil if repo_link.blank?
    parsed = parse_repo
    return nil unless parsed && parsed[:org].present? && parsed[:repo_name].present?
    "https://github.com/#{parsed[:org]}/#{parsed[:repo_name]}/blob/HEAD/bom.csv"
  end

  def bom_file_exists?
    return false if repo_link.blank?
    parsed = parse_repo
    return false unless parsed && parsed[:org].present? && parsed[:repo_name].present?

    path = "/repos/#{parsed[:org]}/#{parsed[:repo_name]}/contents/bom.csv"

    response = if user&.github_user?
      user.fetch_github(path, check_token: true)
    else
      Faraday.get("https://api.github.com#{path}", nil, {
        "Accept" => "application/vnd.github+json",
        "X-GitHub-Api-Version" => "2022-11-28"
      })
    end

    response.status == 200
  rescue StandardError
    false
  end

  def readme_file_url
    return nil if repo_link.blank?
    parsed = parse_repo
    return nil unless parsed && parsed[:org].present? && parsed[:repo_name].present?
    "https://github.com/#{parsed[:org]}/#{parsed[:repo_name]}/blob/HEAD/README.md"
  end

  def readme_file_exists?
    return false if repo_link.blank?
    parsed = parse_repo
    return false unless parsed && parsed[:org].present? && parsed[:repo_name].present?

    path = "/repos/#{parsed[:org]}/#{parsed[:repo_name]}/contents/README.md"

    response = if user&.github_user?
      user.fetch_github(path, check_token: true)
    else
      Faraday.get("https://api.github.com#{path}", nil, {
        "Accept" => "application/vnd.github+json",
        "X-GitHub-Api-Version" => "2022-11-28"
      })
    end

    response.status == 200
  rescue StandardError
    false
  end

  def generate_journal(include_time)
    include_time ||= false

    contents =
    <<~EOS
    <!--
      ===================    !!READ THIS NOTICE!!   ====================
      DO NOT edit this file manually. Your changes WILL BE OVERWRITTEN!
      This journal is auto generated and updated by Hack Club Blueprint.
      To edit this file, please edit your journal entries on Blueprint.
      ==================================================================
    -->

    This is my journal of the design and building process of **#{title}**.#{'  '}
    You can view this journal in more detail on **Hack Club Blueprint** [here](https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}).


    EOS

    journals = journal_entries.order(created_at: :asc)

    day_counts = journals.group_by { |e| e.created_at.to_date }.transform_values(&:size)
    hour_counts = journals.group_by { |e| [ e.created_at.to_date, e.created_at.hour ] }.transform_values(&:size)

    journals.each do |entry|
      t = entry.created_at
      header_ts = if day_counts[t.to_date] && day_counts[t.to_date] > 1
        if hour_counts[[ t.to_date, t.hour ]] && hour_counts[[ t.to_date, t.hour ]] > 1
          t.strftime("%-m/%-d/%Y %-I:%M %p")
        else
          t.strftime("%-m/%-d/%Y %-I %p")
        end
      else
        t.strftime("%-m/%-d/%Y")
      end

      contents += "## #{header_ts}#{entry.summary.present? ? " - #{entry.summary}" : ""}  \n\n"
      if include_time
        contents += "_Time spent: #{(entry.duration_seconds / 3600.0).round(2)}h_  \n\n"
      end
      contents += "#{replace_local_images(entry.content)}  \n\n"
    end

    contents
  end

  def sync_github_jourunal!
    return unless user&.github_user? && repo_link.present?
    GithubJournalSyncJob.perform_later(id)
  end

  def parse_repo
    return { org: nil, repo: nil } if repo_link.blank?

    Project.parse_repo(repo_link)
  end

  def self.tier_options
      tier_amounts = { 1 => "$400 max", 2 => "$200 max", 3 => "$100 max", 4 => "$50 max" }
      Project.tiers.map { |key, value| [ "Tier #{key} (#{tier_amounts[key.to_i]})", value ] }
  end

  def self.tier_max_cents
    { 1 => 40000, 2 => 20000, 3 => 10000, 4 => 5000 }
  end

  def tier_max_cents
    return 0 unless tier.present?
    Project.tier_max_cents[tier] || 0
  end



  def ship!(design: nil)
    unless can_ship?
      throw "Project is already shipped!"
    end

    if Flipper.enabled?(:new_ship_flow_10_06, user)
      if user.ysws_verified.nil? || user.ysws_verified == false
        update!(review_status: :awaiting_idv)
        return
      end
    end

    if !design.nil?
      if design
        update!(review_status: :design_pending)
      else
        update!(review_status: :build_pending)
      end
    else
      if needs_funding?
        update!(review_status: :design_pending)
      else
        update!(review_status: :build_pending)
      end
    end
  end

  def passed_idv!
    ship!
  end

  def under_review?
    design_pending? || build_pending?
  end

  def rejected?
    design_rejected? || build_rejected?
  end

  def can_edit?
    !under_review? && !rejected? && !awaiting_idv?
  end

  def can_ship?
    review_status.nil? || design_needs_revision? || build_needs_revision? || awaiting_idv?
  end

  def followed_by?(user)
    user.followed_projects.include?(self)
  end

  def follower_count
    followers.count
  end

  def view_count
    Ahoy::Event.where(name: "project_view")
      .where("properties @> ?", { project_id: id }.to_json)
      .count("DISTINCT ((properties->>'user_id')::bigint)")
  end

  def dm_status!
    unless user&.slack_id.present?
      Rails.logger.tagged("Project##{id}DM") do
        Rails.logger.warn "User #{user&.id} has no slack_id"
      end
      return
    end

    msg = "Hey <@#{user.slack_id}>!\n\n"

    if awaiting_idv?
      msg += "Your Blueprint project *#{title}* is almost ready to be reviewed! But before we can review your project, you need to verify your identity.\n\nHack Club has given out over $1M in grants to teens like you, and with that comes a lot of adults trying to slip in.\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/auth/idv|Click here to verify your identity>\n\n"
    elsif design_pending?
      msg += "Your Blueprint project *#{title}* is currently waiting for a design review. An inspector will take a look at it soon!\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
    elsif design_needs_revision?
      review = design_reviews.where(result: "returned", invalidated: false).last
      if review && review.feedback.present? && review.reviewer&.slack_id.present?
        msg += "Your Blueprint project *#{title}* needs some changes before it can be approved. Here's some feedback from your inspector, <@#{review.reviewer.slack_id}>:\n\n#{review.feedback}\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
      else
        msg += "Your Blueprint project *#{title}* needs some changes before it can be approved.\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
      end
    elsif design_rejected?
      review = design_reviews.where(result: "rejected", invalidated: false).last
      if review && review.feedback.present? && review.reviewer&.slack_id.present?
        msg += "Your Blueprint project *#{title}* has been rejected. You won't be able to submit again.Here's some feedback from your inspector, <@#{review.reviewer.slack_id}>:\n\n#{review.feedback}\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
      else
        msg += "Your Blueprint project *#{title}* has been rejected. You won't be able to submit again.\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
      end
    else
      msg += "Your Blueprint project *#{title}* has been updated!\n\n<https://#{ENV.fetch("APPLICATION_HOST")}/projects/#{id}|View your project>\n\n"
    end

    SlackDmJob.perform_later(user.slack_id, msg)
  end

  private

  def normalize_repo_link
    normalized = Project.normalize_repo_link(repo_link, user&.github_username)
    self.repo_link = normalized if normalized.present?
  end

  def set_funding_needed_cents_to_zero_if_no_funding
    self.funding_needed_cents = 0 unless needs_funding?
  end

  def funding_needed_within_tier_max
    return unless needs_funding? && tier.present? && funding_needed_cents.present? && funding_needed_cents > 0

    max_cents = tier_max_cents
    if max_cents > 0 && funding_needed_cents > max_cents
      errors.add(:funding_needed_cents, "cannot exceed tier maximum of $#{max_cents / 100.0}")
    end
  end

  def invalidate_design_reviews_on_resubmit
    design_reviews.update_all(invalidated: true)
  end

  def replace_local_images(content)
    return content if content.blank?

    host = ENV.fetch("APPLICATION_HOST")

    # ![alt text](/user-attachments/...) — preserve alt text and avoid double ")"
    content.gsub!(
      /!\[(.*?)\]\((\/user-attachments\/[\S^)]+)(\s+\"[^\"]*\")?\)/,
      "![\\1](https://#{host}\\2\\3)"
    )

    # src="/user-attachments/..."
    content.gsub!(/src=["'](\/user-attachments\/.*?)(?=["'])/, "src=\"https://#{host}\\1\"")

    content
  end
end
