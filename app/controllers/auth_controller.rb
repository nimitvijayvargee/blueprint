class AuthController < ApplicationController
  allow_unauthenticated_access only: %i[ index new create create_email ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to slack_login_url, alert: "Try again later." }

  layout false

  before_action :set_after_login_redirect, only: %i[ index new create_email ]
  before_action :redirect_if_logged_in, only: %i[ index new create create_email ]

  def index
    render "auth/index"
  end

  # Slack auth start
  def new
    if user_logged_in?
      redirect_to(post_login_redirect_path || home_path)
      return
    end

    state = SecureRandom.hex(24)
    session[:state] = state

    params = {
      client_id: ENV.fetch("SLACK_CLIENT_ID", nil),
      redirect_uri: slack_callback_url,
      state: state,
      user_scope: "identity.basic,identity.email,identity.team,identity.avatar",
      team: "T0266FRGM"
    }
    redirect_to "https://slack.com/oauth/v2/authorize?#{params.to_query}", allow_other_host: true
  end

  def create_email
    email = params[:email]
    otp = params[:otp]

    if email.blank? || !(email =~ URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = "Invalid email address."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "flash",
              partial: "shared/notice"
            )
          ]
        end
      end
      return
    end

    if otp.present?
      if validate_otp(email, otp)
        user = User.find_or_create_from_email(email)
        session[:user_id] = user.id
        Rails.logger.info("OTP validated for email: #{email}, OTP: #{otp}")
        redirect_target = post_login_redirect_path
        redirect_to(redirect_target || home_path)
      else
        flash.now[:alert] = "Invalid OTP. Please try again."
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace(
                "flash",
                partial: "shared/notice"
              )
            ]
          end
        end
      end
      return
    end

    if send_otp(email)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "login_form",
            partial: "auth/otp_form",
            locals: { email: email }
          )
        end
      end
    else
      flash.now[:alert] = "Failed to send OTP. Please try again."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "flash",
              partial: "shared/notice",
            ),
            turbo_stream.replace(
              "login_form",
              partial: "auth/email_form"
            )
          ]
        end
      end
    end
  end

  def create
    if params[:state] != session[:state]
      Rails.logger.tagged("Authentication") do
        Rails.logger.error({
          event: "csrf_validation_failed",
          expected_state: session[:state],
          received_state: params[:state]
        }.to_json)
      end
      session[:state] = nil
      redirect_to login_path, alert: "Authentication failed due to CSRF token mismatch"
      return
    end

    begin
      user = User.exchange_slack_token(params[:code], slack_callback_url)
      session[:user_id] = user.id

      Rails.logger.tagged("Authentication") do
        Rails.logger.info({
          event: "authentication_successful",
          user_id: user.id,
          slack_id: user.slack_id
        }.to_json)
      end

      redirect_to(post_login_redirect_path || home_path, notice: "Welcome back, #{user.display_name}!")
    rescue StandardError => e
      Rails.logger.tagged("Authentication") do
        Rails.logger.error({
          event: "authentication_failed",
          error: e.message
        }.to_json)
      end
      redirect_to login_path, alert: e.message
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Signed out successfully. Cya!"
  end

  private

  def redirect_if_logged_in
    return unless user_logged_in?

    redirect_to(post_login_redirect_path || home_path)
  end

  def set_after_login_redirect
    path = safe_redirect_path(params[:redirect_to])
    session[:after_login_redirect] = path if path.present?
  end

  def post_login_redirect_path
    session.delete(:after_login_redirect) || safe_redirect_path(params[:redirect_to])
  end

  def safe_redirect_path(url)
    return nil if url.blank?

    begin
      uri = URI.parse(url)
      if uri.scheme.nil? && uri.host.nil? && uri.path.present? && uri.path.start_with?("/")
        return uri.path + (uri.query.present? ? "?#{uri.query}" : "")
      end
    rescue URI::InvalidURIError
    end

    nil
  end

  def send_otp(email)
    otp = OneTimePassword.create!(email: email)
    otp.send!
  end

  def validate_otp(email, otp)
    OneTimePassword.valid?(otp, email)
  end
end
