class FixNilImageBooleans < ActiveRecord::Migration
  def up
    Image.where(is_owner_avatar: nil).update_all(is_owner_avatar: false)
    Image.where(data_processing: nil).update_all(data_processing: false)
  end

  def down
  end
end
