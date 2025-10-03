class AddGithubInstallationAndExpiryToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :github_installation_id, :bigint
    add_column :users, :github_token_expiry, :datetime
  end
end
