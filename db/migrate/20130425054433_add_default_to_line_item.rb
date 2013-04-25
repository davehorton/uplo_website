class AddDefaultToLineItem < ActiveRecord::Migration
  def up
    change_column :line_items, :commission_percent, :float, :default => 0.0
    add_column :galleries, :has_commission, :boolean, :default => true
  end

  def down
    change_column :line_items, :commission_percent, :float
    remove_column :galleries, :has_commission, :boolean, :default => true
  end
end
