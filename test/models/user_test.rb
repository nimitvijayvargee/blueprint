# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  avatar       :string
#  display_name :string
#  email        :string           not null
#  is_banned    :boolean          default(FALSE), not null
#  role         :integer          default("user"), not null
#  timezone     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slack_id     :string
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
