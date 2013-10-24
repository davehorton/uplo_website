class AddTier5ToProducts < ActiveRecord::Migration
  def up
    add_column :products, :tier5_price, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :products, :tier5_commission, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def down
    remove_column :products, :tier5_price
    remove_column :products, :tier5_commission
  end

end
