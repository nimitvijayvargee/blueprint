class ApplicationController < ActionController::Base
  include Authentication
  include SentryContext
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_paper_trail_whodunnit
  before_action :update_last_active
  before_action :track_ahoy_visit

  def not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  def track_ahoy_visit
    ahoy.track_visit
  end

  def update_last_active
    return unless current_user

    current_user.update_column(:last_active, Time.current)
  end
end
