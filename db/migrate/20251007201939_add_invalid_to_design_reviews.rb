class AddInvalidToDesignReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :design_reviews, :invalid, :boolean, default: false
  end
end
