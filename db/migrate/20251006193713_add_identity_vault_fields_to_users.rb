class AddIdentityVaultFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :identity_vault_access_token, :string
    add_column :users, :identity_vault_id, :string
    add_column :users, :ysws_verified, :boolean
  end
end
