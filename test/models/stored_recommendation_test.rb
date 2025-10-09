# == Schema Information
#
# Table name: stored_recommendations
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  key        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stored_recommendations_on_key  (key) UNIQUE
#
require "test_helper"

class StoredRecommendationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
