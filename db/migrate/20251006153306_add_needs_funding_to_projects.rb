class AddNeedsFundingToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :needs_funding, :boolean, default: true
  end
end
