class GallerySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :permission, :keyword,
             :cover_image, :total_images, :public_link, :last_update, :updated_at
  has_many :images

  def public_link
    object.decorate.public_link
  end
end
