class CreateTimelineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :timeline_items do |t|
      t.references :project, null: false, foreign_key: true
      t.string :type, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end

    add_index :timeline_items, :type
  end
end
