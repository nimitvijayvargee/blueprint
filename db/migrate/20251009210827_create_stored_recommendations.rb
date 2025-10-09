class CreateStoredRecommendations < ActiveRecord::Migration[8.0]
  def change
    create_table :stored_recommendations do |t|
      t.string :key
      t.jsonb :data

      t.timestamps
    end
    add_index :stored_recommendations, :key, unique: true
  end
end
