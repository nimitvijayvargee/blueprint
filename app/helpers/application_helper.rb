module ApplicationHelper
  include Pagy::Frontend

  def admin_namespace?
    controller_path.start_with?("admin/")
  end

  # Shorthand helper for merging Tailwind class strings in views.
  # Accepts strings/arrays/nil values, just like Tailwind.merge.
  def tw(*classes)
    Tailwind.merge(*classes)
  end

  def safe_path(url)
    return nil if url.blank?
    uri = URI.parse(url)
    return nil unless uri.scheme.nil? && uri.host.nil? && uri.path.present? && uri.path.start_with?("/")
    uri.path + (uri.query.present? ? "?#{uri.query}" : "")
  rescue URI::InvalidURIError
    nil
  end
end
