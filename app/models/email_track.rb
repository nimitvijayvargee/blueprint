# == Schema Information
#
# Table name: email_tracks
#
#  id         :bigint           not null, primary key
#  email      :string
#  tracked_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EmailTrack < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tracked_at, presence: true

  before_validation :set_tracked_at, on: :create

  private

  def set_tracked_at
    self.tracked_at ||= Time.current
  end
end
