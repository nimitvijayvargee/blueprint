class AddIndexesToAhoyEvents < ActiveRecord::Migration[8.0]
  def change
    add_index :ahoy_events, [ :user_id, :name ]
    add_index :ahoy_events, "(properties->>'project_id')", name: "index_ahoy_events_on_project_id"
  end
end
