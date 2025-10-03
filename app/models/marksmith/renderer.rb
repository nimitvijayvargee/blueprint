module Marksmith
  # Local override of the gem's renderer with:
  # - Redcarpet configured without underline
  # - External links open in new tab (rel="nofollow noopener" target="_blank"), internal links stay same tab
  # - Optional callouts preprocessing for <aside> blocks
  class Renderer
    def initialize(body:, base_url: nil)
      @body = body.to_s.dup.force_encoding("utf-8")
      @base_url = base_url
    end

    def render
      markdown.render(preprocess_callouts(@body))
    end

    private

    def markdown
      html_renderer = LinkRenderer.new(base_url: @base_url, hard_wrap: true, with_toc_data: true, prettify: true)

      ::Redcarpet::Markdown.new(
        html_renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        lax_spacing: true,
        space_after_headers: true,
        footnotes: false,
        no_intra_emphasis: false,
        no_html: true
      )
    end

    def preprocess_callouts(text)
      return text unless text.include?("<aside")
      text.gsub(%r{<aside(\s[^>]*)?>\s*(.*?)\s*</aside>}m) do
        attrs = Regexp.last_match(1).to_s
        inner_md = Regexp.last_match(2)
        inner_html = markdown.render(inner_md)
        "<aside#{attrs}>#{inner_html}</aside>"
      end
    end

    class LinkRenderer < Redcarpet::Render::HTML
      def initialize(options = {})
        @base_url = options.delete(:base_url)
        super(options)
      end

      def link(href, title, content)
        href = href.to_s
        # Fallback: if href is blank or the default placeholder ("url"), try to derive from the label
        if href.strip.empty? || href.strip.downcase == "url"
          candidate = content.to_s.strip
          if candidate.start_with?("/", "./", "../", "#") || candidate =~ %r{\Ahttps?://}i
            href = candidate
          end
        end

        attrs = []
        attrs << %(href="#{ERB::Util.html_escape(href)}")
        attrs << %(title="#{ERB::Util.html_escape(title)}") if title

        if external_link?(href)
          attrs << %(target="_blank")
          attrs << %(rel="nofollow noopener")
        end

        "<a #{attrs.join(' ')}>#{content}</a>"
      end

      # Handle bare autolinks (e.g., https://example.com) so they get rel/target too
      def autolink(link, link_type)
        href = link.to_s
        if link_type == :email
          return %(<a href="mailto:#{ERB::Util.html_escape(href)}">#{ERB::Util.html_escape(href)}</a>)
        end
        attrs = []
        attrs << %(href="#{ERB::Util.html_escape(href)}")
        if external_link?(href)
          attrs << %(target="_blank")
          attrs << %(rel="nofollow noopener")
        end
        %(<a #{attrs.join(' ')}>#{ERB::Util.html_escape(href)}</a>)
      end

      private

      def external_link?(href)
        # anchors or relative paths are internal
        return false if href.start_with?("#", "/", "./", "../")
        # absolute URL with scheme
        return false unless href =~ %r{\Ahttps?://}i
        return true unless @base_url
        begin
          base = URI.parse(@base_url)
          u = URI.parse(href)
          (base.scheme != u.scheme) || (base.host != u.host) || ((base.port || default_port(base.scheme)) != (u.port || default_port(u.scheme)))
        rescue URI::InvalidURIError
          true
        end
      end

      def default_port(scheme)
        scheme.to_s.downcase == "https" ? 443 : 80
      end
    end
  end
end
