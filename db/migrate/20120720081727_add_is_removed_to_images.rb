class AddIsRemovedToImages < ActiveRecord::Migration
  def change
    add_column :images, :is_removed, :boolean, :default => false
  end
end
