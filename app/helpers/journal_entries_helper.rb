module JournalEntriesHelper
  def render_journal(entry)
    return "" if entry.content.blank?
    entry.rendered_html
  end
end
