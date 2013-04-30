class AddMisssingIndices < ActiveRecord::Migration
  def change
    add_index :carts, :order_id
    add_index :carts, :user_id
    add_index :image_flags, :reported_by
    add_index :image_likes, :user_id
    add_index :image_tags, :tag_id
    add_index :images, :promoted
    add_index :invitations, :token
    add_index :line_items, :image_id
    add_index :line_items, :order_id
    add_index :orders, :user_id
    add_index :profile_images, :user_id
    add_index :profile_images, :link_to_image
    add_index :user_devices, :user_id
    add_index :user_follows, :user_id
    add_index :user_follows, :followed_by
  end
end
