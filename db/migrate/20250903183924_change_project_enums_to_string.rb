class ChangeProjectEnumsToString < ActiveRecord::Migration[8.0]
  def up
    # Convert existing integer values to string equivalents
    change_column :projects, :project_type, :string
    change_column :projects, :review_status, :string

    # Update existing records to use string values
    execute <<-SQL
      UPDATE projects#{' '}
      SET project_type = CASE#{' '}
        WHEN project_type = '0' THEN 'web_app'
        WHEN project_type = '1' THEN 'mobile_app'
        WHEN project_type = '2' THEN 'game'
        WHEN project_type = '3' THEN 'hardware'
        WHEN project_type = '4' THEN 'cli_tool'
        WHEN project_type = '5' THEN 'library'
        WHEN project_type = '6' THEN 'other'
        ELSE project_type
      END
    SQL

    execute <<-SQL
      UPDATE projects#{' '}
      SET review_status = CASE#{' '}
        WHEN review_status = '0' THEN 'pending'
        WHEN review_status = '1' THEN 'approved'
        WHEN review_status = '2' THEN 'rejected'
        WHEN review_status = '3' THEN 'needs_revision'
        ELSE review_status
      END
    SQL
  end

  def down
    # Convert string values back to integers
    execute <<-SQL
      UPDATE projects#{' '}
      SET project_type = CASE#{' '}
        WHEN project_type = 'web_app' THEN '0'
        WHEN project_type = 'mobile_app' THEN '1'
        WHEN project_type = 'game' THEN '2'
        WHEN project_type = 'hardware' THEN '3'
        WHEN project_type = 'cli_tool' THEN '4'
        WHEN project_type = 'library' THEN '5'
        WHEN project_type = 'other' THEN '6'
        ELSE project_type
      END
    SQL

    execute <<-SQL
      UPDATE projects#{' '}
      SET review_status = CASE#{' '}
        WHEN review_status = 'pending' THEN '0'
        WHEN review_status = 'approved' THEN '1'
        WHEN review_status = 'rejected' THEN '2'
        WHEN review_status = 'needs_revision' THEN '3'
        ELSE review_status
      END
    SQL

    change_column :projects, :project_type, :integer
    change_column :projects, :review_status, :integer
  end
end
