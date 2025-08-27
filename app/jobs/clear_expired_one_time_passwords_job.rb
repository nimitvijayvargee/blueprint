class ClearExpiredOneTimePasswordsJob < ApplicationJob
  queue_as :cleanup

  def perform(*args)
    OneTimePassword.find_each do |otp|
      otp.destroy if otp.expired?
    end
  end
end
