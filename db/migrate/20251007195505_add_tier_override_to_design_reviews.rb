class AddTierOverrideToDesignReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :design_reviews, :tier_override, :integer
  end
end
