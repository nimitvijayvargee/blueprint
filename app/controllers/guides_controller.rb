class GuidesController < ApplicationController
  def show
    slug = params[:slug].to_s
    slug = "" if slug.blank?
    not_found unless valid_slug?(slug)

    base = Rails.root.join("docs", "guides")

    candidates = if slug.blank?
      [ base.join("index.md") ]
    else
      [
        base.join("#{slug}.md"),
        base.join(slug, "index.md")
      ]
    end

    path = candidates.find { |p| File.exist?(p.to_s) }
    not_found unless path

    @title = File.basename(path, ".md").presence || "index"
    @content_html = helpers.render_markdown_file(path)
  end

  private

  def valid_slug?(slug)
    return true if slug == ""
    return false if slug.include?("..") || slug.start_with?("/")

    slug.match?(%r{\A[a-z0-9_\-/]+\z})
  end
end
