class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    # Automatically extract UTM parameters from request
    if request && request.params
      data[:utm_source] = request.params["utm_source"] if request.params["utm_source"].present?
      data[:utm_medium] = request.params["utm_medium"] if request.params["utm_medium"].present?
      data[:utm_campaign] = request.params["utm_campaign"] if request.params["utm_campaign"].present?
      data[:utm_content] = request.params["utm_content"] if request.params["utm_content"].present?
      data[:utm_term] = request.params["utm_term"] if request.params["utm_term"].present?
    end

    super(data)
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
