# == Schema Information
#
# Table name: design_reviews
#
#  id                   :bigint           not null, primary key
#  admin_review         :boolean
#  feedback             :text
#  grant_override_cents :integer
#  hours_override       :float
#  invalidated          :boolean          default(FALSE)
#  reason               :string
#  result               :integer
#  tier_override        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  project_id           :bigint           not null
#  reviewer_id          :bigint           not null
#
# Indexes
#
#  index_design_reviews_on_project_id                  (project_id)
#  index_design_reviews_on_reviewer_id                 (reviewer_id)
#  index_design_reviews_on_reviewer_id_and_project_id  (reviewer_id,project_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (reviewer_id => users.id)
#
require "test_helper"

class DesignReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
