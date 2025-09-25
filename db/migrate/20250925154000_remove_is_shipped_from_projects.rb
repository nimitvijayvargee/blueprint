class RemoveIsShippedFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :is_shipped, :boolean
  end
end
