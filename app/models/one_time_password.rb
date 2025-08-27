# == Schema Information
#
# Table name: one_time_passwords
#
#  id         :bigint           not null, primary key
#  expires_at :datetime
#  secret     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_one_time_passwords_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OneTimePassword < ApplicationRecord
  belongs_to :user

  before_validation :generate, on: :create

  validates :secret, :expires_at, presence: true

  def expired?
    Time.current > expires_at
  end

  private

  def generate
    self.secret ||= SecureRandom.random_number(1000000).to_s.rjust(6, "0")
    self.expires_at ||= 15.minutes.from_now
  end
end
