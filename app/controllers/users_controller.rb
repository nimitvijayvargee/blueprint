class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  def show
    @user = User.find_by(id: params[:id])
    not_found unless @user
  end

  def invite_to_slack
    current_user.invite_to_slack!
    render json: { ok: true, status: "done", user_id: current_user.id }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end

  def mcg_check
    current_user.refresh_profile!
    render json: { ok: true, status: "done", user_id: current_user.id, is_mcg: current_user.is_mcg? }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end
end
