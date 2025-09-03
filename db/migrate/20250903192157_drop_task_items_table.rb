class DropTaskItemsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :task_items, if_exists: true do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false, null: false
      t.references :task_list, null: false, foreign_key: true
      t.timestamps
    end
  end
end
