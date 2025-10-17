class UniqueProjectViewTracker
  # Records a unique view. Returns true if this was the first view for (project, user).
  def self.record(project_id:, user_id:)
    return false if user_id.blank?

    sql = <<~SQL
      WITH ins AS (
        INSERT INTO project_user_views (project_id, user_id, first_viewed_at)
        VALUES (?, ?, NOW())
        ON CONFLICT (project_id, user_id) DO NOTHING
        RETURNING 1
      )
      UPDATE projects p
      SET views_count = p.views_count + 1
      FROM ins
      WHERE p.id = ?
      RETURNING TRUE AS inserted;
    SQL

    res = ActiveRecord::Base.connection.exec_query(
      ActiveRecord::Base.send(:sanitize_sql_array, [ sql, project_id, user_id, project_id ])
    )

    res.any?
  end
end
