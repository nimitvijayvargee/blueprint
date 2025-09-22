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
end
