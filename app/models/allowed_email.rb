# == Schema Information
#
# Table name: allowed_emails
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_allowed_emails_on_email  (email) UNIQUE
#
class AllowedEmail < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  before_validation do
    self.email = email.to_s.strip.downcase
  end

  def self.allowed?(email)
    return true unless Flipper.enabled?(:whitelist_emails)
    return false if email.blank?
    exists?(email: email.to_s.strip.downcase)
  end
end
