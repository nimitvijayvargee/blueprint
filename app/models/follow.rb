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

  after_commit :sync_to_gorse, on: :create
  after_commit :delete_from_gorse, on: :destroy
  after_commit :notify_project_owner, on: :create

  private

  def cannot_follow_own_project
    return unless user_id == project.user_id

    errors.add(:user_id, "You cannot follow your own project")
  end

  def sync_to_gorse
    GorseSyncFollowJob.perform_later(id)
  end

  def delete_from_gorse
    GorseService.delete_feedback("follow", user_id, GorseService.project_item_id(project_id))
  rescue => e
    Rails.logger.error("Failed to delete follow #{id} from Gorse: #{e.message}")
    Sentry.capture_exception(e)
  end

  def notify_project_owner
    return unless project.user.slack_id.present?

    host = ENV.fetch("APPLICATION_HOST", "blueprint.hackclub.com")
    url_helpers = Rails.application.routes.url_helpers

    follower_name = if user.slack_id.present?
      "<@#{user.slack_id}>"
    else
      user_url = url_helpers.user_url(user, host: host)
      display_name = user.display_name || user.username || "Someone"
      "<#{user_url}|#{display_name}>"
    end

    project_url = url_helpers.project_url(project, host: host)
    project_link = "<#{project_url}|#{project.title}>"

    message = "#{follower_name} just followed your project #{project_link}! 🎉"

    SlackDmJob.perform_later(project.user.slack_id, message)
  rescue => e
    Rails.logger.error("Failed to send follower notification for follow #{id}: #{e.message}")
    Sentry.capture_exception(e)
  end
end
