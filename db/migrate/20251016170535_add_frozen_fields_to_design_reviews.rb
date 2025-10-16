class AddFrozenFieldsToDesignReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :design_reviews, :frozen_funding_needed_cents, :integer
    add_column :design_reviews, :frozen_duration_seconds, :integer
    add_column :design_reviews, :frozen_tier, :integer
    add_column :design_reviews, :frozen_entry_count, :integer
  end
end
