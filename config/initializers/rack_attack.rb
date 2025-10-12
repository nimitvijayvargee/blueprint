class Rack::Attack
  # Throttle POST /auth/email by IP (5 requests per minute)
  throttle("auth/email/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/auth/email" && req.post?
  end

  # Throttle POST /auth/email by email parameter (3 requests per minute)
  throttle("auth/email/email", limit: 3, period: 1.minute) do |req|
    if req.path == "/auth/email" && req.post?
      req.params["email"]&.downcase
    end
  end

  # Throttle POST /auth/track by IP (10 requests per minute)
  throttle("auth/track/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/auth/track" && req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [
      429,
      { "Content-Type" => "text/plain" },
      [ "Rate limit exceeded. Please try again later.\n" ]
    ]
  end
end
