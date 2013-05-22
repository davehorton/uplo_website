class AddProductOptionToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :product_option_id, :integer
  end
end
