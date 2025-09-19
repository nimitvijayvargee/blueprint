module Marksmith
  module SanitizerHelper
    def sanitize_marksmith_html(html)
      sanitized = sanitize(html.to_s, tags: allowed_marksmith_tags, attributes: allowed_marksmith_attributes)

      doc = Nokogiri::HTML::DocumentFragment.parse(sanitized)
      doc.css('a[href]').each do |a|
        # Always overwrite rel on all anchors to prevent user-injected values
        a['rel'] = 'nofollow noopener'

        href = a['href'].to_s
        if external_link?(href)
          # Only add target when not provided; do not override existing target
          a['target'] = a['target'].presence || '_blank'
        end
      end
      doc.to_html.html_safe
    end

    private

    def allowed_marksmith_tags
      ( %w[table th tr td span em strong i] +
        ActionView::Helpers::SanitizeHelper.sanitizer_vendor.safe_list_sanitizer.allowed_tags.to_a
      ).uniq
    end

    def allowed_marksmith_attributes
      ( %w[href rel target src alt title width height class] +
        ActionView::Helpers::SanitizeHelper.sanitizer_vendor.safe_list_sanitizer.allowed_attributes.to_a
      ).uniq
    end

    def external_link?(href)
      return false if href.start_with?('#', '/', './', '../')
      return false unless href =~ /\Ahttps?:\/\//i

      base_url = request.base_url rescue nil
      return true if base_url.blank?

      begin
        base = URI.parse(base_url)
        u = URI.parse(href)
        (base.scheme != u.scheme) || (base.host != u.host) || ((base.port || default_port(base.scheme)) != (u.port || default_port(u.scheme)))
      rescue URI::InvalidURIError
        true
      end
    end

    def default_port(scheme)
      scheme.to_s.downcase == 'https' ? 443 : 80
    end
  end
end
