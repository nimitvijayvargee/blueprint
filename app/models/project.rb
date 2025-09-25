# == Schema Information
#
# Table name: projects
#
#  id                     :bigint           not null, primary key
#  demo_link              :string
#  description            :text
#  hackatime_project_keys :string           default([]), is an Array
#  is_deleted             :boolean          default(FALSE)
#  project_type           :string
#  readme_link            :string
#  repo_link              :string
#  review_status          :string
#  tier                   :integer
#  title                  :string
#  views_count            :integer          default(0), not null
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
  has_many :journal_entries
  has_many :timeline_items, dependent: :destroy
  has_many :follows, dependent: :destroy
  has_many :followers, through: :follows, source: :user

  # Enums
  enum :project_type, {
    custom: "custom"
  }

  enum :review_status, {
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
  after_update_commit :sync_github_jourunal!, if: -> { saved_change_to_repo_link? && repo_link.present? }

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
    users = User.where(id: user_ids).index_by { |u| u.id.to_s }

    ship_design_events.each do |event|
      user = users[event[:whodunnit].to_s]
      timeline << { type: :ship_design, date: event[:timestamp], user: user }
    end

    timeline
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

  def generate_journal
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
      [ [ "Select a tier...", "" ] ] + Project.tiers.map { |key, value| [ "Tier #{key}", value ] }
  end

  def ship_design
    unless review_status.nil?
      throw "Project is already shipped!"
    end

    update!(review_status: :design_pending)
  end

  def under_review?
    review_status == "design_pending" || review_status == "build_pending"
  end

  def rejected?
    review_status == "design_rejected" || review_status == "build_rejected"
  end

  def can_edit?
    !under_review? && !rejected?
  end

  private

  def normalize_repo_link
    normalized = Project.normalize_repo_link(repo_link, user&.github_username)
    self.repo_link = normalized if normalized.present?
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
