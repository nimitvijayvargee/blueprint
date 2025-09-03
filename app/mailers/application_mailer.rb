class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(ENV.fetch("EMAIL_FROM", "from@example.com"), ENV.fetch("EMAIL_NAME", "Blueprint"))
  layout "mailer"
end
