class Admin::ApplicationController < ApplicationController
  layout "admin"
  before_action :require_perms!
  before_action :set_paper_trail_whodunnit

  private

  def require_perms!
    unless current_user&.special_perms?
      redirect_to main_app.root_path, alert: "You are not authorized to access this page."
    end
  end
end
