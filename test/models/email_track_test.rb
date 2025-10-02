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
require "test_helper"

class EmailTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
