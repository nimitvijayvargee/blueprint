class RemoveDevlogsCountFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :devlogs_count, :integer
  end
end
