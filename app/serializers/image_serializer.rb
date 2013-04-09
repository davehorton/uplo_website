class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_file_name, :gallery_id,
             :price, :image_likes_count, :keyword, :owner_avatar, :gallery_cover, :tier_id,
             :image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
             :public_link, :user_id, :user_avatar, :comments_number, :gallery_name

  def public_link
    object.decorate.public_link
  end

  def creation_timestamp
    object.decorate.creation_timestamp
  end
end
