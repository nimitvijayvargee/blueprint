class GorseService
  class << self
    def sync_user(user)
      response = with_retry do
        connection.post("/api/user") do |req|
          req.headers["X-API-KEY"] = api_key
          req.headers["Content-Type"] = "application/json"
          req.body = {
            UserId: user.id.to_s,
            Labels: [],
            Comment: ""
          }.to_json
        end
      end

      handle_response(response, "sync user #{user.id}")
    end

    def delete_user(user)
      response = with_retry do
        connection.delete("/api/user/#{user.id}") do |req|
          req.headers["X-API-KEY"] = api_key
        end
      end

      handle_response(response, "delete user #{user.id}")
    end

    def sync_item(project)
      last_updated = project.updated_at
      if project.journal_entries.loaded?
        latest_journal_update = project.journal_entries.maximum(&:updated_at)
        last_updated = [ last_updated, latest_journal_update ].compact.max
      elsif project.respond_to?(:latest_journal_update) && project.latest_journal_update
        last_updated = [ last_updated, project.latest_journal_update ].compact.max
      end

      response = with_retry do
        connection.post("/api/item") do |req|
          req.headers["X-API-KEY"] = api_key
          req.headers["Content-Type"] = "application/json"
          req.body = {
            ItemId: project.id.to_s,
            IsHidden: project.is_deleted || false,
            Categories: [],
            Timestamp: last_updated.iso8601,
            Labels: [ project.tier ].compact,
            Comment: ""
          }.to_json
        end
      end

      handle_response(response, "sync item #{project.id}")
    end

    def delete_item(project)
      response = with_retry do
        connection.delete("/api/item/#{project.id}") do |req|
          req.headers["X-API-KEY"] = api_key
        end
      end

      handle_response(response, "delete item #{project.id}")
    end

    def sync_feedback(feedback_type, user_id, item_id, timestamp)
      response = with_retry do
        connection.post("/api/feedback") do |req|
          req.headers["X-API-KEY"] = api_key
          req.headers["Content-Type"] = "application/json"
          req.body = [ {
            FeedbackType: feedback_type,
            UserId: user_id.to_s,
            ItemId: item_id.to_s,
            Timestamp: timestamp.iso8601
          } ].to_json
        end
      end

      handle_response(response, "sync feedback #{feedback_type} user=#{user_id} item=#{item_id}")
    end

    def delete_feedback(feedback_type, user_id, item_id)
      response = with_retry do
        connection.delete("/api/feedback/#{feedback_type}/#{user_id}/#{item_id}") do |req|
          req.headers["X-API-KEY"] = api_key
        end
      end

      handle_response(response, "delete feedback #{feedback_type} user=#{user_id} item=#{item_id}")
    end

    private

    def base_url
      ENV.fetch("GORSE_API_URL", "https://gorse.blueprint.a.selfhosted.hackclub.com")
    end

    def api_key
      ENV.fetch("GORSE_ADMIN_API_KEY")
    end

    def connection
      @connection ||= Faraday.new(url: base_url) do |f|
        f.adapter Faraday.default_adapter
      end
    end

    def handle_response(response, action)
      unless response.success?
        raise "Failed to #{action}: #{response.status} - #{response.body}"
      end

      JSON.parse(response.body)
    end

    def with_retry(max = 3)
      retries = 0
      begin
        yield
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, SocketError => e
        retries += 1
        if retries <= max
          Rails.logger.warn "Gorse request failed (try #{retries}/#{max + 1}): #{e.message}"
          sleep(0.5 * retries)
          retry
        else
          Rails.logger.error "Gorse request failed after retry: #{e.message}"
          Sentry.capture_exception(e)
          raise
        end
      end
    end
  end
end
