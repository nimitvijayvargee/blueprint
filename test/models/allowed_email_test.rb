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
require "test_helper"

class AllowedEmailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
