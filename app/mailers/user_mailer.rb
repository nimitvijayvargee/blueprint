class UserMailer < ApplicationMailer
  def otp_email
    @user = params[:user]
    @otp = "12345"
    mail(to: @user.email, subject: "Hackworks login code: #{@otp}")
  end
end
