class AddLastActiveToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :last_active, :date
  end
end
