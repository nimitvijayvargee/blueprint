class GithubJournalSyncJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find_by(id: project_id)
    user = project&.user

    unless project && user && user.github_user? && project.repo_link.present?
      Rails.logger.tagged("GithubJournalSyncJob") do
        Rails.logger.error({ event: "project_cannot_sync", project_id: project_id }.to_json)
      end
      raise StandardError, "Project cannot be synced"
      nil
    end

    content = project.generate_journal(false)

    begin
      org, repo = project.parse_repo.values_at(:org, :repo_name)
      get_response = user.fetch_github("/repos/#{org}/#{repo}/contents/JOURNAL.md")

      if get_response.status == 200
        result = JSON.parse(get_response.body)
        sha = result["sha"]
      else
        Rails.logger.tagged("GithubJournalSyncJob") do
          Rails.logger.info({ event: "journal_not_found", project_id: project_id, status: get_response.status }.to_json)
        end
      end

      put_response = user.fetch_github(
        "/repos/#{org}/#{repo}/contents/JOURNAL.md",
        method: :put,
        data: { message: sha.present? ? "Update JOURNAL.md" : "Create JOURNAL.md", content: Base64.strict_encode64(content), sha: sha }.compact,
        headers: { "Content-Type" => "application/json" }
      )

      if put_response.status.in?([ 200, 201 ])
        Rails.logger.tagged("GithubJournalSyncJob") do
          Rails.logger.info({ event: "journal_synced", project_id: project_id, status: put_response.status }.to_json)
        end
      else
        puts put_response.body
        Rails.logger.tagged("GithubJournalSyncJob") do
          Rails.logger.error({ event: "journal_sync_failed", project_id: project_id, status: put_response.status }.to_json)
        end
        raise StandardError, "Failed to sync journal"
      end
    rescue StandardError => e
      Rails.logger.tagged("GithubJournalSyncJob") do
        Rails.logger.error({ event: "journal_sync_exception", project_id: project_id, error: e.message }.to_json)
      end
      raise
    end
  end
end
