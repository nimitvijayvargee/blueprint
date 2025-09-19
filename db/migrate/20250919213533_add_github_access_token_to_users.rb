class AddGithubAccessTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :github_access_token, :string
  end
end
