module JournalEntriesHelper
  def render_journal(entry)
    return "" if entry.content.blank?
    marksmithed(entry.content)
  end
end
