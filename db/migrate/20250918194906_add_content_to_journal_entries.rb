class AddContentToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :journal_entries, :content, :text
  end
end
