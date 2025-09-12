class RenameDisplayNameToUsernameOnUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :display_name, :username
  end
end
