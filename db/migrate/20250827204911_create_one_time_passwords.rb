class CreateOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :one_time_passwords do |t|
      t.references :user, null: false, foreign_key: true
      t.string :secret, null: false
      t.datetime :expires_at

      t.timestamps
    end
  end
end
