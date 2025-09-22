class CreateShopOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :shop_orders do |t|
      t.integer :state, null: false, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :shop_item, null: false, foreign_key: true
      t.integer :frozen_unit_ticket_cost
      t.integer :frozen_unit_usd_cost
      t.integer :quantity
      t.string :internal_notes

      t.datetime :approved_at
      t.references :approved_by, foreign_key: { to_table: :users }

      t.datetime :fufilled_at
      t.references :fufilled_by, foreign_key: { to_table: :users }
      t.integer :fufillment_usd_cost

      t.datetime :rejected_at
      t.references :rejected_by, foreign_key: { to_table: :users }
      t.string :rejection_reason

      t.datetime :on_hold_at
      t.references :on_hold_by, foreign_key: { to_table: :users }
      t.string :hold_reason

      t.jsonb :frozen_address

      t.timestamps
    end
  end
end
