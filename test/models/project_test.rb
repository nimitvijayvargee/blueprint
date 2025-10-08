# == Schema Information
#
# Table name: projects
#
#  id                     :bigint           not null, primary key
#  demo_link              :string
#  description            :text
#  funding_needed_cents   :integer          default(0), not null
#  hackatime_project_keys :string           default([]), is an Array
#  is_deleted             :boolean          default(FALSE)
#  needs_funding          :boolean          default(TRUE)
#  project_type           :string
#  readme_link            :string
#  repo_link              :string
#  review_status          :string
#  tier                   :integer
#  title                  :string
#  views_count            :integer          default(0), not null
#  ysws                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_projects_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
