class GallerySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :permission, :keyword,
             :cover_image_url, :total_images, :public_link, :last_update, :updated_at

  def public_link
    object.decorate.public_link
  end

  def cover_image_url
    cover_image = object.cover_image
    cover_image.image_thumb_url if cover_image
  end
end
