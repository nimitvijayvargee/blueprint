# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  avatar              :string
#  email               :string           not null
#  github_access_token :string
#  github_username     :string
#  is_banned           :boolean          default(FALSE), not null
#  is_mcg              :boolean          default(FALSE), not null
#  role                :integer          default("user"), not null
#  timezone            :string
#  username            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  slack_id            :string
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
