# 🐒🛠️

# This is a fixup to bring the ref param we're using to track source into Ahoy.
module Ahoy
  class VisitProperties
    def utm_properties
      landing_params = {}
      begin
        landing_uri = URI.parse(landing_page)
        # could also use Rack::Utils.parse_nested_query
        landing_params = CGI.parse(landing_uri.query) if landing_uri
      rescue
        # do nothing
      end

      props = {}
      %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |name|
        props[name.to_sym] = params[name] || landing_params[name].try(:first)
      end
      ### v PATCH v ###
      props[:utm_source] ||= params[:ref] || landing_params["ref"].try(:first)
      ### ^ PATCH ^ ###
      props
    end
  end
end
