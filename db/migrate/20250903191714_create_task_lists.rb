class CreateTaskLists < ActiveRecord::Migration[8.0]
  def change
    create_table :task_lists do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
