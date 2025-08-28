class UpdateUsersMakeFieldsOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :display_name, true
    change_column_null :users, :avatar, true
    change_column_null :users, :slack_id, true
  end
end
