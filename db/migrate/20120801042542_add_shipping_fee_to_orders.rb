class AddShippingFeeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_fee, :float, :default => 0
  end
end
