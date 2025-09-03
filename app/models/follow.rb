# == Schema Information
#
# Table name: follows
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_follows_on_project_id              (project_id)
#  index_follows_on_user_id                 (user_id)
#  index_follows_on_user_id_and_project_id  (user_id,project_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#
class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user_id, uniqueness: { scope: :project_id, message: "already follows this project" }
  validate :cannot_follow_own_project

  private

  def cannot_follow_own_project
    return unless user_id == project.user_id

    errors.add(:user_id, "You cannot follow your own project")
  end
end
