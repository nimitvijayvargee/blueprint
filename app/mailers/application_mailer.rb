class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("EMAIL_FROM", "from@example.com")
  layout "mailer"
end
