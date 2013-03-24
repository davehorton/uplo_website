class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :tier_id
      t.string :size_id
      t.string :moulding_id
      t.decimal :price,      :precision => 10, :scale => 0, :default => 0
      t.decimal :commission, :precision => 10, :scale => 0, :default => 0

      t.timestamps
    end
    add_index :products, :tier_id
    add_index :products, :size_id
    add_index :products, :moulding_id
  end
end
