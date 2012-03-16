class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :image_id
      t.integer :quantity
      t.float :tax
      t.float :price
      t.boolean :plexi_mount
      t.string :moulding
      t.string :size

      t.timestamps
    end
  end
end
