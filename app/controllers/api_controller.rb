class ApiController < ApplicationController
  allow_unauthenticated_access only: %i[ site stickers ]
  skip_forgery_protection only: %i[ stickers ]
  before_action :authenticate_api, only: %i[ stickers ]

  def site
    render plain: "#{Project.where(is_deleted: false).count} projects made"
  end

  def stickers
    # check to make sure the request has slack_id and blueprint_id
    slack_id = params[:slack_id]
    blueprint_id = params[:blueprint_id]
    unless slack_id.present? && blueprint_id.present?
      render json: { ok: false, error: "Missing fields" }, status: :bad_request
      return
    end

    user = User.find_by(id: blueprint_id, slack_id: slack_id)
    unless user
      render json: { ok: false, error: "User not found" }, status: :not_found
      return
    end

    eligible = user.tasks.completed?
    render json: { ok: true, eligible: eligible }
  end

  private

  def authenticate_api
    unless ENV["BLUEPRINT_API_KEY"].present?
      raise "BLUEPRINT_API_KEY environment variable is not set"
    end

    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV["BLUEPRINT_API_KEY"] || "")
    end
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unauthorized
  end
end
