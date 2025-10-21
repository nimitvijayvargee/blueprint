class GorseSyncViewJob < ApplicationJob
  queue_as :default

  def perform(user_id, item_id, timestamp)
    project = Project.find(item_id)
    GorseService.sync_feedback("view", user_id, project, timestamp)
  rescue => e
    Rails.logger.error("Failed to sync view feedback to Gorse: #{e.message}")
    Sentry.capture_exception(e)
    raise
  end
end
