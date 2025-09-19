class DropActionTextTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :action_text_rich_texts, if_exists: true
  end

  def down
    create_table :action_text_rich_texts do |t|
      t.string     :name, null: false
      t.text       :body
      t.references :record, null: false, polymorphic: true, index: false
      t.timestamps
    end

    add_index :action_text_rich_texts, [ :record_type, :record_id, :name ], name: :index_action_text_rich_texts_uniqueness, unique: true
  end
end
