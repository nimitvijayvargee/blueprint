class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  def show
    @user = User.find_by(id: params[:id])
    not_found unless @user
  end

  def invite_to_slack
    user = current_user
    unless user
      render json: { ok: false, error: "unauthorized" }, status: :unauthorized
      return
    end

    user.invite_to_slack!
    render json: { ok: true, status: "done", user_id: user.id }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end
end
