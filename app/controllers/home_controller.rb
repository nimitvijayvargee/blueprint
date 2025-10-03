class HomeController < ApplicationController
  def index
    @projects = current_user.projects.where(is_deleted: false).includes(:banner_attachment)
  end
end
