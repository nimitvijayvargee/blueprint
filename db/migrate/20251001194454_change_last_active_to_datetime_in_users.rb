class ChangeLastActiveToDatetimeInUsers < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :last_active, :datetime
  end

  def down
    change_column :users, :last_active, :date
  end
end
