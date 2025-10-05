class ReferralController < ApplicationController
  allow_unauthenticated_access

  def show
    referrer_id = params[:id]

    unless params[:ref] == "r"
      redirect_to root_path, alert: "Invalid referral link"
      return
    end

    unless User.exists?(id: referrer_id)
      redirect_to root_path, alert: "Invalid referral link"
      return
    end

    # Set referrer cookie with 30-day expiration
    cookies[:referrer_id] = {
      value: referrer_id,
      expires: 30.days.from_now,
      httponly: true
    }

    ahoy.track "referral_click", {
      referrer_id: referrer_id
    }

    redirect_to root_path
  end
end
