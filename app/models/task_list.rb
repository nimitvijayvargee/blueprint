# == Schema Information
#
# Table name: task_lists
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_task_lists_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class TaskList < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  def task_requirements
    {
      create_project: {
        met: user.projects.any?,
        errorMsg: "You must create your first project",
        successMsg: "You have created your first project!"
      },
      write_journal_entry: {
        met: user.journal_entries.any?,
        errorMsg: "You must write your first journal entry",
        successMsg: "You have written your first journal entry!"
      },
      follow_project: {
        met: user.follows.any?,
        errorMsg: "You must follow another user's project",
        successMsg: "You have followed another user's project!"
      },
      complete_profile: {
        met: user.display_name.present? && user.avatar.present?,
        errorMsg: "You must complete your profile with a display name and avatar",
        successMsg: "You have completed your profile!"
      }
    }
  end

  def completed_tasks
    task_requirements.select { |_, req| req[:met] }
  end

  def pending_tasks
    task_requirements.reject { |_, req| req[:met] }
  end

  def completion_percentage
    return 0 if task_requirements.empty?
    (completed_tasks.count.to_f / task_requirements.count * 100).round(1)
  end

  def task_status(task_name)
    req = task_requirements[task_name]
    return nil unless req

    req[:met] ? req[:successMsg] : req[:errorMsg]
  end
end
