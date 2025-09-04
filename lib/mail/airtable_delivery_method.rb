module Mail
  class AirtableDeliveryMethod
    def initialize(values)
      # values is a hash of options from config.action_mailer.airtable_delivery_method_settings
    end

    def deliver!(mail)
      Faraday.post(ENV["EMAIL_AIRTABLE_WEBHOOK"], {
        token: ENV["EMAIL_TOKEN"],
        email: mail.to,
        subject: mail.subject,
        body: mail.body.to_s
      }.to_json, { "Content-Type" => "application/json" })
    end
  end
end
