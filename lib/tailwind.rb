# frozen_string_literal: true

# Global Tailwind utilities
#
# Provides a single merger instance for Tailwind class conflict resolution
# and a convenience merge method usable from anywhere (models, helpers, views).
#
# Usage:
#   Tailwind.merge("p-2 p-4", some_condition && "p-6")
#   #=> "p-6"
#
# In views you can also use the `tw` helper (see ApplicationHelper).
module Tailwind
  class << self
    # Returns a memoized TailwindMerge::Merger instance
    def merger
      @merger ||= TailwindMerge::Merger.new
    end

    # Merge any number of class lists into a single Tailwind-safe string.
    # - Accepts strings, arrays, and nil/false values (which are ignored)
    # - Flattens and compacts inputs, then merges with tailwind_merge
    def merge(*classes)
      flat = classes.flatten.compact.map(&:to_s).reject(&:empty?)
      return "" if flat.empty?

      merger.merge(flat.join(" "))
    end
  end
end
