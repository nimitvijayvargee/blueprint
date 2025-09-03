class DropTasksTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :tasks, if_exists: true do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
