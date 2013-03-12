class AddImageLikesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_likes_count, :integer, default: 0
    add_index :users, :image_likes_count
  end
end
