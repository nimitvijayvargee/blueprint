class AddIsMcgToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_mcg, :boolean, default: false, null: false
  end
end
