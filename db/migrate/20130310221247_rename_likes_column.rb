class RenameLikesColumn < ActiveRecord::Migration
  def change
    rename_column :images, :likes, :image_likes_count
    add_index :images, :image_likes_count
  end
end
