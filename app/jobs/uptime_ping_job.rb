class UptimePingJob < ApplicationJob
  queue_as :uptime

  def perform
    url = "https://uptime.hackclub.com/api/push/DbF8jziMBq?status=up&msg=OK&ping="

    begin
      response = Faraday.get(url)

      if response.success?
        Rails.logger.info "Uptime ping successful: #{response.status}"
      else
        Rails.logger.warn "Uptime ping failed with status: #{response.status}"
      end
    rescue => e
      Rails.logger.error "Uptime ping error: #{e.message}"
      # Don't re-raise to avoid job failure - we'll try again in 60 seconds
    end
  end
end
