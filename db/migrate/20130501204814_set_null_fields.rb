class SetNullFields < ActiveRecord::Migration
  def up
    [ :addresses,
      :carts,
      :comments,
      :galleries,
      :gallery_invitations,
      :image_flags,
      :image_likes,
      :image_tags,
      :images,
      :invitations,
      :line_items,
      :mouldings,
      :orders,
      :products,
      :profile_images,
      :sizes,
      :tags,
      :user_devices,
      :user_follows,
      :users ].each do |table|
        change_column table, :created_at, :datetime, :null => false
        change_column table, :updated_at, :datetime, :null => false
      end
  end

  def down
  end
end
