class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :data_file_name, :name, :gallery_id,
             :price, :image_likes_count, :keyword, :owner_avatar, :gallery_cover, :tier,
             :image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
             :public_link, :user_id, :user_avatar, :comments_number, :gallery_name
end
