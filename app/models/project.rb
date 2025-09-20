# == Schema Information
#
# Table name: projects
#
#  id                     :bigint           not null, primary key
#  demo_link              :string
#  description            :text
#  hackatime_project_keys :string           default([]), is an Array
#  is_deleted             :boolean          default(FALSE)
#  is_shipped             :boolean          default(FALSE)
#  project_type           :string
#  readme_link            :string
#  repo_link              :string
#  review_status          :string
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
  has_many :follows, dependent: :destroy
  has_many :followers, through: :follows, source: :user

  # Enums
  enum :project_type, {
    custom: "custom"
  }

  enum :review_status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected",
    needs_revision: "needs_revision"
  }

  validates :title, presence: true
  validates :description, presence: true
  has_one_attached :banner

  before_validation :normalize_repo_link

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

  def generate_timeline
    timeline = []

    timeline << { type: :creation, date: created_at }

    journal_entries.order(created_at: :asc).each do |entry|
      timeline << { type: :journal, date: entry.created_at, entry: entry }
    end

    timeline
  end

  private

  def normalize_repo_link
    raw = self.repo_link.to_s.strip
    return if raw.blank?

    parsed = Project.parse_repo(raw)
    return unless parsed

    org = parsed[:org] || self.user&.github_username
    repo = parsed[:repo_name]

    return if org.blank? || repo.blank?

    self.repo_link = "https://github.com/#{org}/#{repo}"
  end
end
