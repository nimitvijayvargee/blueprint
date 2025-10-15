class CreateProjectGrants < ActiveRecord::Migration[8.0]
  def change
    create_table :project_grants do |t|
      t.integer :tier
      t.integer :grant_cents
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
