class AddFundingNeededCentsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :funding_needed_cents, :integer, default: 0, null: false
  end
end
