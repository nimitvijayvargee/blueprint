# == Schema Information
#
# Table name: projects
#
#  id                     :bigint           not null, primary key
#  demo_link              :string
#  description            :text
#  devlogs_count          :integer          default(0), not null
#  hackatime_project_keys :string           default([]), is an Array
#  is_deleted             :boolean          default(FALSE)
#  is_shipped             :boolean          default(FALSE)
#  project_type           :string
#  readme_link            :string
#  repo_link              :string
#  review_status          :string
#  title                  :string
#  views_count            :integer          default(0), not null
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
class Project < ApplicationRecord
  belongs_to :user
  has_many :journal_entries
  has_many :follows, dependent: :destroy
  has_many :followers, through: :follows, source: :user

  # Enums
  enum :project_type, {
    custom: "custom"
  }

  enum :review_status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected",
    needs_revision: "needs_revision"
  }

  validates :title, presence: true
  has_one_attached :banner
end
