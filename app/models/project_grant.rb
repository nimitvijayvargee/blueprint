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
class ProjectGrant < ApplicationRecord
  belongs_to :project

  enum :tier, {
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5
  }, prefix: true

  validates :grant_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
