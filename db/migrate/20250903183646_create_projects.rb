class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :demo_link
      t.string :readme_link
      t.string :repo_link
      t.integer :project_type
      t.integer :review_status
      t.boolean :is_shipped, default: false
      t.boolean :is_deleted, default: false
      t.integer :views_count, default: 0, null: false
      t.integer :devlogs_count, default: 0, null: false
      t.string :hackatime_project_keys, array: true, default: []
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
