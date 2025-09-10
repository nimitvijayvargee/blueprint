class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  def show
    @user = User.find_by(id: params[:id])
    not_found unless @user
  end
end
