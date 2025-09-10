class GuidesController < ApplicationController
  allow_unauthenticated_access only: %i[ show hardware starter_projects ]
  skip_before_action :set_current_user, if: :turbo_frame_request?

  def hardware
    render_from_base Rails.root.join("docs", "hardware-guides"), params[:slug]
  end

  def starter_projects
    render_from_base Rails.root.join("docs", "starter-projects"), params[:slug]
  end

  private

  def render_from_base(base, slug)
    slug = slug.to_s
    slug = "" if slug.blank?
    not_found unless valid_slug?(slug)

    candidates = if slug.blank?
      [ base.join("index.md") ]
    else
      [ base.join("#{slug}.md"), base.join(slug, "index.md") ]
    end

    path = candidates.find { |p| File.exist?(p.to_s) }
    not_found unless path

    @title = File.basename(path, ".md").presence || "index"
    @content_html = helpers.render_markdown_file(path)

    if turbo_frame_request?
      render("frame", layout: false)
    else
      render("show")
    end
  end

  def valid_slug?(slug)
    return true if slug == ""
    return false if slug.include?("..") || slug.start_with?("/")

    slug.match?(%r{\A[a-z0-9_\-/]+\z})
  end
end
