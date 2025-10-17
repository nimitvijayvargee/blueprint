# == Schema Information
#
# Table name: project_user_views
#
#  id              :bigint           not null, primary key
#  first_viewed_at :datetime         not null
#  project_id      :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_project_user_views_on_user_id  (user_id)
#  index_puv_on_project_id_user_id      (project_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#
class ProjectUserView < ApplicationRecord
  belongs_to :project
  belongs_to :user
end
