class AddCommissionPercentToLineItems < ActiveRecord::Migration
  def change
  	add_column :line_items, :commission_percent, :float
  end
end
