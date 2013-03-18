class ChangeGalleryPermissionDefault < ActiveRecord::Migration
  def up
    change_column_default :galleries, :permission, nil
  end

  def down
  end
end
