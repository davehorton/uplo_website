class ChangeGalleryPermission < ActiveRecord::Migration
  def change
    remove_column :galleries, :permission
    add_column :galleries, :permission, :integer, :default => 1
  end
end
