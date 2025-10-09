class AddPrintLegionToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :print_legion, :boolean, default: false, null: false
  end
end
