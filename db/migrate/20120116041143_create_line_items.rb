class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :image_id
      t.integer :quantity, :default => 0
      t.float :tax, :default => 0
      t.float :price, :default => 0
      t.boolean :plexi_mount, :default => false
      t.string :moulding
      t.string :size

      t.timestamps
    end
  end
end
