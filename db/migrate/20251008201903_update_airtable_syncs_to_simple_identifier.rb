class UpdateAirtableSyncsToSimpleIdentifier < ActiveRecord::Migration[8.0]
  def change
    remove_column :airtable_syncs, :syncable_type, :string
    remove_column :airtable_syncs, :syncable_id, :bigint

    add_column :airtable_syncs, :record_identifier, :string, null: false
    add_index :airtable_syncs, :record_identifier, unique: true
  end
end
