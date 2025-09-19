# == Schema Information
#
# Table name: journal_entries
#
#  id               :bigint           not null, primary key
#  content          :text
#  duration_seconds :integer          default(0), not null
#  views_count      :integer          default(0), not null
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
end
