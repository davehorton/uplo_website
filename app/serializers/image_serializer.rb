class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_file_name, :gallery_id,
             :image_likes_count, :keyword, :owner_avatar, :gallery_cover, :tier_id,
             :image_url, :image_thumb_url, :username, :creation_timestamp, :fullname,
             :public_link, :user_id, :user_avatar, :comments_number, :gallery_name, :products, :in_private_gallery

  def public_link
    object.decorate.public_link
  end

  def creation_timestamp
    object.decorate.creation_timestamp
  end

  def products
    viewing_own_image = (scope && scope.id == object.user_id)

    options = []
    object.available_products.each do |product|
      options << {
        id:          product.id,
        name:        "#{product.size.to_name} - #{product.moulding.name}",
        size_name:   product.size.to_name,
        mould_name:  product.moulding.name,
        price:       "%0.2f" % product.price_for_tier(object.tier_id, viewing_own_image),
        product_options: product.product_options.map {|po| ProductOptionSerializer.new(po, root: false)}
      }
    end
    options
  end

  def in_private_gallery
    !object.gallery.is_public?
  end
end
