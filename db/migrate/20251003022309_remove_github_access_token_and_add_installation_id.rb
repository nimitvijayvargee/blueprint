class RemoveGithubAccessTokenAndAddInstallationId < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :github_access_token, :string
    remove_column :users, :github_token_expiry, :datetime
  end
end
