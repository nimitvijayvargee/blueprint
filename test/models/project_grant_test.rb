# == Schema Information
#
# Table name: project_grants
#
#  id          :bigint           not null, primary key
#  grant_cents :integer
#  tier        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_project_grants_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
require "test_helper"

class ProjectGrantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
