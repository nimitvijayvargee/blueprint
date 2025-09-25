class AddTierToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :tier, :integer
  end
end
