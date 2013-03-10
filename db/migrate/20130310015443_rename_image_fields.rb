class RenameImageFields < ActiveRecord::Migration
  def up
    rename_column :images, :is_gallery_cover, :gallery_cover
    rename_column :images, :is_owner_avatar, :owner_avatar
    rename_column :images, :is_removed, :removed

    add_index :images, :gallery_cover
    add_index :images, :removed
  end

  def down
  end
end
