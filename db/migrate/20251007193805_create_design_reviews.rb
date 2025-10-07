class CreateDesignReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :design_reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :project, null: false, foreign_key: true
      t.float :hours_override
      t.boolean :admin_review
      t.string :reason
      t.integer :grant_override_cents

      t.timestamps
    end
  end
end
