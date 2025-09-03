class AuthMailer < ApplicationMailer
  def otp_email
    @email = params[:email]
    @otp = params[:otp]
    mail(to: @email, subject: "Blueprint login code: #{@otp}")
  end
end
