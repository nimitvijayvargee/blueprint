class CreateKudos < ActiveRecord::Migration[8.0]
  def change
    create_table :kudos do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
