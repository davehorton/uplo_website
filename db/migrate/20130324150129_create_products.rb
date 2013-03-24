class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :tier_id
      t.integer :size_id
      t.integer :moulding_id
      t.decimal :price,      :precision => 8, :scale => 2, :default => 0
      t.decimal :commission, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
    add_index :products, :tier_id
    add_index :products, :size_id
    add_index :products, :moulding_id
  end
end
