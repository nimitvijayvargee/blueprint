class UpdateUniqueIndexForNonInvalidatedReviews < ActiveRecord::Migration[8.0]
  def change
    remove_index :design_reviews, [:reviewer_id, :project_id]
    add_index :design_reviews, [:reviewer_id, :project_id], unique: true, where: "invalidated = false"
  end
end
