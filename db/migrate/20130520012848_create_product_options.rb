class CreateProductOptions < ActiveRecord::Migration
  def change
    create_table :product_options do |t|
      t.integer :product_id
      t.string  :description
      t.decimal :border_top_bottom, precision: 8, scale: 2, default: 0
      t.decimal :border_left_right, precision: 8, scale: 2, default: 0
      t.timestamps
    end

    add_index :product_options, :product_id
  end
end
