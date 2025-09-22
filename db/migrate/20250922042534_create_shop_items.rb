class CreateShopItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shop_items do |t|
      t.boolean :enabled
      t.integer :ticket_cost
      t.integer :usd_cost
      t.string :name
      t.string :desc
      t.boolean :one_per_person
      t.integer :total_stock
      t.string :type

      t.timestamps
    end
  end
end
