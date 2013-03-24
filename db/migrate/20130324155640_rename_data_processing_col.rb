class RenameDataProcessingCol < ActiveRecord::Migration
  def up
    rename_column :images, :data_processing, :image_processing
  end

  def down
  end
end
