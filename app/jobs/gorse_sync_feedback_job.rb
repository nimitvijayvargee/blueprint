class GorseSyncFeedbackJob < ApplicationJob
  queue_as :default

  def perform(feedback_type, user_id, item_id, timestamp)
    GorseService.sync_feedback(feedback_type, user_id, item_id, timestamp)
  rescue => e
    Rails.logger.error("Failed to sync #{feedback_type} feedback to Gorse: #{e.message}")
    Sentry.capture_exception(e)
    raise
  end
end
