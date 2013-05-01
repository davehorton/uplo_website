class SetDefaultGalleryPermission < ActiveRecord::Migration
  def up
    change_column :galleries, :permission, :string, :default => 'public'

    Gallery.where(permission: nil).update_all(permission: 'public')
  end

  def down
  end
end
