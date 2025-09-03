class LandingController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    if user_logged_in?
      redirect_to home_path
    else
      render layout: false
    end
    # This will render app/views/landing/index.html.erb without layout
  end
end
