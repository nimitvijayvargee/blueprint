class CreateAirtableSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :airtable_syncs do |t|
      t.references :syncable, polymorphic: true, null: false
      t.string :airtable_id
      t.datetime :last_synced_at
      t.string :synced_attributes_hash

      t.timestamps
    end
  end
end
