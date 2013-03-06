class ImageImprovements < ActiveRecord::Migration
  def change
    change_column :images, :is_owner_avatar, :boolean, :default => false
    change_column :images, :data_processing, :boolean, :default => false

    add_index :images, :gallery_id
    add_index :images, :data_processing
    add_index :images, :is_removed

    add_index :image_flags, :image_id
    add_index :image_likes, :image_id
    add_index :image_tags, :image_id

    add_index :galleries, :user_id
  end
end
