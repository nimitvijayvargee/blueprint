require "redcarpet"
require "uri"

module GuidesHelper
  class GuidesLinkRenderer < Redcarpet::Render::HTML
    def initialize(options = {})
      @base_url = options[:base_url]
      super
    end

    def link(href, title, content)
      href = href.to_s
      attrs = []
      attrs << %(href="#{ERB::Util.html_escape(href)}")
      attrs << %(title="#{ERB::Util.html_escape(title)}") if title

      if guide_internal_link?(href)
        attrs << %(data-turbo-frame="guide_content")
        attrs << %(data-turbo-action="advance")
      elsif !same_origin?(href)
        attrs << %(target="_blank")
        attrs << %(rel="nofollow noopener")
      end

      "<a #{attrs.join(' ')}>#{content}</a>"
    end

    def guide_internal_link?(href)
      return false if href.start_with?("#")
      return true  if href.start_with?("./", "../")
      if href.start_with?("/")
        return href.start_with?("/guides", "/hardware-guides", "/starter-projects")
      end
      # No scheme or root slash: treat as relative within guides
      return false if href =~ /\A[a-z][a-z0-9+.-]*:/i
      true
    end

    private

    def same_origin?(href)
      return true if href.start_with?("/", "#", "./", "../")
      return false unless href =~ /\Ahttps?:\/\//i
      return false unless @base_url

      begin
        base = URI.parse(@base_url)
        u = URI.parse(href)
        base.scheme == u.scheme && base.host == u.host && (base.port || default_port(base.scheme)) == (u.port || default_port(u.scheme))
      rescue URI::InvalidURIError
        false
      end
    end

    def default_port(scheme)
      scheme.to_s.downcase == "https" ? 443 : 80
    end
  end

  def render_markdown(text)
    base_url = request.base_url rescue nil

    if defined?(@__markdown_renderer_base_url).nil? || @__markdown_renderer_base_url != base_url || @__markdown_renderer.nil?
      renderer = GuidesLinkRenderer.new(
        with_toc_data: true,
        hard_wrap: true,
        filter_html: false,
        prettify: true,
        base_url: base_url
      )
      @__markdown_renderer = Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        lax_spacing: true,
        space_after_headers: true,
        footnotes: true
      )
      @__markdown_renderer_base_url = base_url
    end

    @__markdown_renderer.render(text).html_safe
  end

  GUIDES_HTML_CACHE = ActiveSupport::Cache::MemoryStore.new(size: 32.megabytes)

  def render_markdown_file(path)
    base_url = request.base_url rescue nil
    key = [ "guide_md_html", path.to_s, File.mtime(path).to_i, base_url ]
    GUIDES_HTML_CACHE.fetch(key) do
      render_markdown(File.read(path))
    end
  end
end
