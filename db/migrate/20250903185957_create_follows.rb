class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    # Add unique index to prevent duplicate follows
    add_index :follows, [ :user_id, :project_id ], unique: true
  end
end
