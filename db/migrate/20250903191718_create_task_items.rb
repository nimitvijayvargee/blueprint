class CreateTaskItems < ActiveRecord::Migration[8.0]
  def change
    create_table :task_items do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false, null: false
      t.references :task_list, null: false, foreign_key: true

      t.timestamps
    end

    add_index :task_items, :completed
  end
end
