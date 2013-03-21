class DropLastUsed < ActiveRecord::Migration
  def up
    remove_column :profile_images, :last_used
  end

  def down
  end
end
