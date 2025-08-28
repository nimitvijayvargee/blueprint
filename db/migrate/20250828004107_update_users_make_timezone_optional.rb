class UpdateUsersMakeTimezoneOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :timezone, true
  end
end
