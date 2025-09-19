module Marksmith
  module MarksmithHelper
    def marksmithed(body)
      base_url = request.base_url rescue nil
      Marksmith::Renderer.new(body:, base_url: base_url).render
    end

    # Allow passing custom classes to toolbar buttons.
    def marksmith_toolbar_button(name, hotkey_scope: nil, hotkey: nil, **kwargs)
      extra_class = kwargs.delete(:class)
      classes = class_names(marksmith_button_classes, extra_class)

      content_tag "md-#{name}", marksmith_toolbar_svg(name),
        title: t("marksmith.#{name.to_s.tr("-", "_")}").humanize,
        class: classes,
        data: {
          hotkey_scope: hotkey_scope,
          hotkey: hotkey
        }.compact
    end
  end
end
