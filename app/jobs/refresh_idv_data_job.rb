class RefreshIdvDataJob < ApplicationJob
  queue_as :background

  def perform
    User.find_each do |user|
      user.refresh_idv_data!
    end
  end
end
