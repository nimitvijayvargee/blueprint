require "redcarpet"

module GuidesHelper
  def render_markdown(text)
    @__markdown_renderer ||= begin
      renderer = Redcarpet::Render::HTML.new(
        with_toc_data: true,
        hard_wrap: true,
        filter_html: true
      )
      Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        lax_spacing: true,
        space_after_headers: true,
        footnotes: true
      )
    end

    @__markdown_renderer.render(text).html_safe
  end

  GUIDES_HTML_CACHE = ActiveSupport::Cache::MemoryStore.new(size: 32.megabytes)

  def render_markdown_file(path)
    key = ["guide_md_html", path.to_s, File.mtime(path).to_i]
    GUIDES_HTML_CACHE.fetch(key) do
      render_markdown(File.read(path))
    end
  end
end
