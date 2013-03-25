class AddProductIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :product_id, :integer
    add_index  :line_items, :product_id
  end
end
