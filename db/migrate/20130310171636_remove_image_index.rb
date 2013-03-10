class RemoveImageIndex < ActiveRecord::Migration
  def up
    remove_index :images, :name => 'index_images_on_is_removed'
  end

  def down
  end
end
