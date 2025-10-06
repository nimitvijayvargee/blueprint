class AddYswsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :ysws, :string
  end
end
