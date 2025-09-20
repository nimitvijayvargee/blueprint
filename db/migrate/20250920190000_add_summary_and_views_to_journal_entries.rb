class AddSummaryAndViewsToJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :journal_entries, :summary, :string
    add_column :journal_entries, :views, :bigint, array: true, default: [], null: false
    remove_column :journal_entries, :views_count, :integer
  end
end
