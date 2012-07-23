class AddIsPromotedToImages < ActiveRecord::Migration
  def change
    add_column :images, :is_promoted, :boolean, :default => false
  end
end
