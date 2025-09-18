# == Schema Information
#
# Table name: journal_entries
#
#  id               :bigint           not null, primary key
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

  has_rich_text :content

  has_one_attached :attachment
end
