module PaperTrailHelper
  # Finds version event(s) where a given attribute changed, with optional filters.
  # Params:
  # - object: AR model instance with has_paper_trail
  # - attribute: Symbol/String attribute name
  # - before: optional value the attribute changed from
  # - after: optional value the attribute changed to
  # - whodunnit: optional string/id to match version.whodunnit
  # - all: boolean (default: false). When true, returns all matching events (Array of Hashes). When false, returns the first match (Hash) or nil.
  # Returns:
  # - all: false → Hash with keys: :before, :after, :timestamp, :whodunnit; or nil if not found
  # - all: true  → Array of Hashes described above (possibly empty)
  def attribute_updated_event(object:, attribute:, before: nil, after: nil, whodunnit: nil, all: false)
    raise ArgumentError, "object must respond to versions" unless object.respond_to?(:versions)

    attr = attribute.to_s

    scope = object.versions.where(event: "update")
    # Require that this attribute is present in object_changes
    scope = scope.where("object_changes ? :attr", attr: attr)

    if before
      scope = scope.where("object_changes->:attr->>0 = :before", attr: attr, before: before.to_s)
    end

    if after
      scope = scope.where("object_changes->:attr->>1 = :after", attr: attr, after: after.to_s)
    end

    if whodunnit
      scope = scope.where(whodunnit: whodunnit.to_s)
    end

    ordered = scope.order(:created_at, :id)

    if all
      return ordered.map { |v|
        change = v.object_changes[attr]
        {
          before: change&.first,
          after: change&.last,
          timestamp: v.created_at,
          whodunnit: v.whodunnit
        }
      }
    end

    v = ordered.first
    return nil unless v

    change = v.object_changes[attr]
    {
      before: change&.first,
      after: change&.last,
      timestamp: v.created_at,
      whodunnit: v.whodunnit
    }
  end
end
