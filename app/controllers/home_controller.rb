class HomeController < ApplicationController
  def index
    @projects = current_user.projects.with_attached_banner
  end
end
