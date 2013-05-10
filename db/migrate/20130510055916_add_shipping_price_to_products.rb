class AddShippingPriceToProducts < ActiveRecord::Migration
  def up
    add_column :products, :shipping_price, :decimal, :precision => 8, :scale => 2, :default => 0.00
  end

  def down
    remove_column :products, :shipping_price
  end
end
