class CreateProjectUserViews < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :project_user_views do |t|
      t.bigint :project_id, null: false
      t.bigint :user_id, null: false
      t.datetime :first_viewed_at, null: false, default: -> { "NOW()" }
    end

    add_index :project_user_views, [ :project_id, :user_id ], unique: true, algorithm: :concurrently, name: "index_puv_on_project_id_user_id"
    add_index :project_user_views, :user_id, algorithm: :concurrently

    add_foreign_key :project_user_views, :projects
    add_foreign_key :project_user_views, :users
  end
end
