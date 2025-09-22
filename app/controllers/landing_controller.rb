class LandingController < ApplicationController
  allow_unauthenticated_access only: %i[index authed]

  def index
    if user_logged_in?
      redirect_to home_path
    else
      render layout: false
    end
    # This will render app/views/landing/index.html.erb without layout
  end

  def authed
    redirect_to root_path and return unless user_logged_in?

    render "landing/index", layout: false
  end
end
