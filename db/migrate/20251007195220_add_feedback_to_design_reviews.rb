class AddFeedbackToDesignReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :design_reviews, :feedback, :text
  end
end
