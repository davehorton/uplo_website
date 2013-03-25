class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :size_id
      t.integer :moulding_id
      t.decimal :tier1_price, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier2_price, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier3_price, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier4_price, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier1_commission, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier2_commission, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier3_commission, :precision => 8, :scale => 2, :default => 0
      t.decimal :tier4_commission, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
    add_index :products, :size_id
    add_index :products, :moulding_id
  end
end
