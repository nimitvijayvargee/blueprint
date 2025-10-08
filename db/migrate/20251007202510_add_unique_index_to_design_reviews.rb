class AddUniqueIndexToDesignReviews < ActiveRecord::Migration[8.0]
  def change
    # Remove duplicate reviews first
    execute <<-SQL
      DELETE FROM design_reviews
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM design_reviews
        GROUP BY reviewer_id, project_id
      )
    SQL

    add_index :design_reviews, [ :reviewer_id, :project_id ], unique: true
  end
end
