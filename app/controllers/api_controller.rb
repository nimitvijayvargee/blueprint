class ApiController < ApplicationController
  allow_unauthenticated_access only: %i[ site ]

  def site
    render plain: "#{Project.where(is_deleted: false).count} projects made"
  end
end
