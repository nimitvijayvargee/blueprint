class HomeController < ApplicationController
  def index
    @projects = current_user.projects.includes(:banner_attachment)
  end
end
