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
require "test_helper"

class OneTimePasswordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
