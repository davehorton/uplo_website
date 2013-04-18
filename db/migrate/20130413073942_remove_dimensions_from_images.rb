class RemoveDimensionsFromImages < ActiveRecord::Migration
  def up
    remove_column :images, :width
    remove_column :images, :height
  end

  def down
  end
end
