class AddForeignKeys < ActiveRecord::Migration
  def up
    add_foreign_key :carts, :users
    add_foreign_key :carts, :orders
    add_foreign_key :comments, :users
    add_foreign_key :comments, :images
    add_foreign_key :galleries, :users
    add_foreign_key :gallery_invitations, :galleries
    add_foreign_key :image_flags, :images
    add_foreign_key :image_flags, :users, :column => :reported_by
    add_foreign_key :image_likes, :images
    add_foreign_key :image_likes, :users
    add_foreign_key :image_tags, :images
    add_foreign_key :image_tags, :tags
    add_foreign_key :images, :users
    add_foreign_key :images, :galleries
    add_foreign_key :line_items, :images
    add_foreign_key :line_items, :products
    add_foreign_key :line_items, :orders
    add_foreign_key :orders, :users
    add_foreign_key :orders, :addresses, :column => :billing_address_id
    add_foreign_key :orders, :addresses, :column => :shipping_address_id
    add_foreign_key :products, :sizes
    add_foreign_key :products, :mouldings
    add_foreign_key :profile_images, :users
    add_foreign_key :profile_images, :images, :column => :link_to_image
    add_foreign_key :user_devices, :users
    add_foreign_key :user_follows, :users
    add_foreign_key :user_follows, :users, :column => :followed_by
    add_foreign_key :users, :addresses, :column => :billing_address_id
    add_foreign_key :users, :addresses, :column => :shipping_address_id
  end

  def down
    remove_foreign_key :carts, { :column => :user_id }
    remove_foreign_key :carts, { :column => :order_id }
    remove_foreign_key :comments, { :column => :user_id }
    remove_foreign_key :comments, { :column => :image_id }
    remove_foreign_key :galleries, { :column => :user_id }
    remove_foreign_key :gallery_invitations, { :column => :gallery_id }
    remove_foreign_key :image_flags, { :column => :image_id }
    remove_foreign_key :image_likes, { :column => :image_id }
    remove_foreign_key :image_likes, { :column => :user_id }
    remove_foreign_key :image_tags, { :column => :image_id }
    remove_foreign_key :image_tags, { :column => :tag_id }
    remove_foreign_key :images, { :column => :gallery_id }
    remove_foreign_key :images, { :column => :user_id }
    remove_foreign_key :line_items, { :column => :image_id }
    remove_foreign_key :line_items, { :column => :order_id }
    remove_foreign_key :line_items, { :column => :product_id }
    remove_foreign_key :orders, { :column => :user_id }
    remove_foreign_key :products, { :column => :size_id }
    remove_foreign_key :products, { :column => :moulding_id }
    remove_foreign_key :profile_images, { :column => :user_id }
    remove_foreign_key :user_devices, { :column => :user_id }
    remove_foreign_key :user_follows, { :column => :user_id }
    remove_foreign_key :image_flags, { :column => :reported_by }
    remove_foreign_key :orders, { :column => :billing_address_id }
    remove_foreign_key :orders, { :column => :shipping_address_id }
    remove_foreign_key :profile_images, { :column => :link_to_image}
    remove_foreign_key :user_follows, { :column => :followed_by }
    remove_foreign_key :users, { :column => :billing_address_id }
    remove_foreign_key :users, { :column => :shipping_address_id }
  end
end
