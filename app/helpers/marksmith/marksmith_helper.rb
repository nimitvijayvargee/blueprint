module Marksmith
  module MarksmithHelper
    # Override to allow passing custom classes to toolbar buttons.
    # Usage in views:
    #   <%= marksmith_toolbar_button "bold", class: "my-custom-class" %>
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
