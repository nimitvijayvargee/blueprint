# == Schema Information
#
# Table name: journal_entries
#
#  id               :bigint           not null, primary key
#  content          :text
#  duration_seconds :integer          default(0), not null
#  summary          :string
#  views            :bigint           default([]), not null, is an Array
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_journal_entries_on_project_id  (project_id)
#  index_journal_entries_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#
class JournalEntry < ApplicationRecord
  belongs_to :user
  belongs_to :project

  has_one_attached :attachment

  MIN_CHARS = 250

  validate :content_min_chars_excluding_images
  validate :content_must_include_image
  validates :summary, presence: true, length: { maximum: 60 }

  after_commit :sync_project_github_journal, on: %i[create update destroy]

  def rendered_html
    return "" if content.blank?

    Rails.cache.fetch("journal_entry_html/#{cache_key_with_version}", expires_in: 1.week) do
      base_url = Rails.application.routes.default_url_options[:host] || "localhost:3000"
      Marksmith::Renderer.new(body: content, base_url: "http://#{base_url}").render
    end
  end

  private

  def content_min_chars_excluding_images
    body = content.to_s
    without_images = body.gsub(/!\[[^\]]*\]\([^)]+\)/, "")
    normalized = without_images.lines.map { |l| l.strip }.join
    if normalized.length < MIN_CHARS
      errors.add(:content, "is too short; add more details (min #{MIN_CHARS} characters excluding images)")
    end
  end

  def content_must_include_image
    body = content.to_s
    images = body.scan(/!\[[^\]]*\]\([^)]+\)/)
    if images.size < 1
      errors.add(:content, "must include at least one image")
    end
  end

  def sync_project_github_journal
    project&.sync_github_journal!
  end
end
