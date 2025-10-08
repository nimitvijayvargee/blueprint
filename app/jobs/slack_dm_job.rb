class SlackDmJob < ApplicationJob
  queue_as :default

  def perform(slack_id, message)
    client = Slack::Web::Client.new(token: ENV.fetch("SLACK_BLUEY_TOKEN", nil))

    client.chat_postMessage(
      channel: slack_id,
      text: message
    )
  rescue StandardError => e
    Rails.logger.tagged("SlackDMJob") do
      Rails.logger.error({ event: "slack_dm_failed", slack_id: slack_id, error: e.message }.to_json)
    end
    raise e
  end
end
