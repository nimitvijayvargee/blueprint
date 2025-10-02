class RenameTimezoneToTimezoneRawOnUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :timezone, :timezone_raw
  end
end
