class RenameMinimumSizeFields < ActiveRecord::Migration
  def up
    rename_column :sizes, :minimum_recommended_width, :minimum_width_in_pixels
    rename_column :sizes, :minimum_recommended_height, :minimum_height_in_pixels
  end

  def down
  end
end
