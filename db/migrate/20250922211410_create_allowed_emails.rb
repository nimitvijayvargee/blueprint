class CreateAllowedEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :allowed_emails do |t|
      t.string :email

      t.timestamps
    end
    add_index :allowed_emails, :email, unique: true
  end
end
