class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :image_id
      t.float :price
      t.string :moulding
      t.string :size

      t.timestamps
    end
  end
end
