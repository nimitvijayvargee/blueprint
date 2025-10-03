module GithubHelper
  def self.generate_jwt
    private_pem = Base64.decode64(ENV["GITHUB_APP_PRIVATE_KEY"])
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      iat: Time.now.to_i - 60,
      # expires in 10 minutes
      exp: Time.now.to_i + (10 * 60),
      iss: ENV["GITHUB_APP_CLIENT_ID"]

    }

    JWT.encode(payload, private_key, "RS256")
  end

  def self.get_installation_token(installation_id)
    jwt = generate_jwt

    url = "https://api.github.com/app/installations/#{installation_id}/access_tokens"
    response = Faraday.post(url) do |req|
      req.headers["Authorization"] = "Bearer #{jwt}"
      req.headers["Accept"] = "application/vnd.github+json"
      req.headers["X-GitHub-Api-Version"] = "2022-11-28"
    end

    if response.status == 201
      body = JSON.parse(response.body)
      body
    elsif response.status == 404
      nil
    else
      raise "Failed to get installation token: #{response.status} - #{response.body}"
    end
  end
end
