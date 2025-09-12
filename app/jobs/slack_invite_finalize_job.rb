class SlackInviteFinalizeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    begin
      user.finalize_slack_invite!
    rescue StandardError => e
      Rails.logger.tagged("SlackInviteJob") do
        Rails.logger.error({ event: "invite_finalize_job_failed", user_id: user_id, error: e.message }.to_json)
      end
      raise
    end
  end
end
