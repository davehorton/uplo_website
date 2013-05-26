class CreateShippingPrices < ActiveRecord::Migration
  def change
    create_table :shipping_prices do |t|
      t.integer :product_id
      t.integer :quantity
      t.decimal :amount, :precision => 8,  :scale => 2
      t.timestamps
    end

    add_index :shipping_prices, :product_id
  end
end
