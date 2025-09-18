class RemoveTextFromJournalEntries < ActiveRecord::Migration[8.0]
  def change
    remove_column :journal_entries, :text, :text
  end
end
