class UpdateGalleryPermission < ActiveRecord::Migration
  def up
    change_column :galleries, :permission, :string

    Gallery.update_all({ permission: 'private' }, { permission: '0' })
    Gallery.update_all({ permission: 'public' }, { permission: '1' })

    add_index :galleries, :permission
  end

  def down
  end
end
