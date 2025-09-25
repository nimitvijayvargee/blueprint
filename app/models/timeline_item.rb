# == Schema Information
#
# Table name: timeline_items
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#
# Indexes
#
#  index_timeline_items_on_project_id  (project_id)
#  index_timeline_items_on_type        (type)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class TimelineItem < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :project

  validates :type, presence: true
  validates :data, presence: true
end
