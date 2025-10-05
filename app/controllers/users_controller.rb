class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  def show
    @user = User.find_by(id: params[:id])
    not_found unless @user
  end

  def me
    redirect_to user_path(current_user)
  end

  def invite_to_slack
    ahoy.track("slack_user_create", user_id: current_user&.id)
    current_user.invite_to_slack!
    render json: { ok: true, status: "done", user_id: current_user.id }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end

  def mcg_check
    current_user.refresh_profile!
    if current_user.is_mcg?
      ahoy.track("slack_login", from_mcg: true, user_id: current_user&.id)
    end
    render json: { ok: true, status: "done", user_id: current_user.id, is_mcg: current_user.is_mcg? }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end

  def update_timezone
    unless current_user
      render json: { ok: false, error: "Not authenticated" }, status: :unauthorized
      return
    end

    timezone = params[:timezone]
    if timezone.blank?
      render json: { ok: false, error: "Timezone parameter is required" }, status: :bad_request
      return
    end

    if current_user.update_timezone(timezone)
      render json: { ok: true, status: "updated", timezone: current_user.timezone_raw }
    else
      render json: { ok: false, error: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :internal_server_error
  end
end
