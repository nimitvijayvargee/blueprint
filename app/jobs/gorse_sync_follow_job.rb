class GorseSyncFollowJob < ApplicationJob
  queue_as :default

  def perform(follow_id)
    follow = Follow.find(follow_id)
    GorseSyncFeedbackJob.perform_later("follow", follow.user_id, follow.project_id, follow.created_at)
  rescue => e
    Rails.logger.error("Failed to sync follow #{follow_id} to Gorse: #{e.message}")
    Sentry.capture_exception(e)
    raise
  end
end
