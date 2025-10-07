class RenameInvalidToInvalidatedInDesignReviews < ActiveRecord::Migration[8.0]
  def change
    rename_column :design_reviews, :invalid, :invalidated
  end
end
