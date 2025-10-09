class AddApprovedFieldsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :approved_tier, :integer
    add_column :projects, :approved_funding_cents, :integer
  end
end
