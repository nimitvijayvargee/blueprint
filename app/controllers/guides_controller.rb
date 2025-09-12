class GuidesController < ApplicationController
  allow_unauthenticated_access only: %i[ show guides starter_projects ]
  skip_before_action :set_current_user, if: :turbo_frame_request?

  def guides
    render_from_base Rails.root.join("docs", "guides"), params[:slug]
  end

  def starter_projects
    render_from_base Rails.root.join("docs", "starter-projects"), params[:slug]
  end

  def faq
    render_from_base Rails.root.join("docs"), "faq"
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

    # SEO metadata from optional table at top of markdown
    meta = { title: nil, description: nil }
    suffix = "Blueprint"
    index_title = "Blueprint"

    case
    when base.to_s.end_with?("guides")
      url_prefix = "/guides"
      suffix = "Blueprint Guides"
      index_title = "Guides - Blueprint"
      current_url = slug.blank? ? url_prefix : "#{url_prefix}/#{slug}"
      item = helpers.guide_meta_for_url(current_url) rescue nil
      meta[:title] = item[:title] if item
      meta[:description] = item[:description] if item
    when base.to_s.end_with?("starter-projects")
      url_prefix = "/starter-projects"
      suffix = "Blueprint Starter Projects"
      index_title = "Starter Projects - Blueprint"
      current_url = slug.blank? ? url_prefix : "#{url_prefix}/#{slug}"
      item = helpers.starter_project_meta_for_url(current_url) rescue nil
      meta[:title] = item[:title] if item
      meta[:description] = item[:description] if item
    else
      begin
        meta = helpers.send(:parse_guide_metadata, path)
      rescue NoMethodError
        meta = { title: nil, description: nil }
      end
    end

    @guide_meta = meta
    if slug.blank?
      @page_title = index_title
    else
      base_title = meta[:title].presence || @title
      @page_title = [ base_title, suffix ].compact.join(" - ")
    end
    @page_description = meta[:description].presence

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
