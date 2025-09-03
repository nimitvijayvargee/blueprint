# == Schema Information
#
# Table name: task_lists
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_task_lists_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class TaskListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
