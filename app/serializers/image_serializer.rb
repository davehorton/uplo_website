class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_file_name, :gallery_id,
             :image_likes_count, :keyword, :owner_avatar, :gallery_cover, :tier_id,
             :image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
             :public_link, :user_id, :user_avatar, :comments_number, :gallery_name, :products

  def public_link
    object.decorate.public_link
  end

  def creation_timestamp
    object.decorate.creation_timestamp
  end

  def products
    options = []
    object.available_products.each do |product|
      options << {
        id:          product.id,
        name:        "#{product.size.to_name} - #{product.moulding.name}",
        size_name:   product.size.to_name,
        mould_name:  product.moulding.name,
        price:       "%0.2f" % product.price_for_tier(object.tier_id),
        product_options: product.product_options.map {|po| ProductOptionSerializer.new(po, root: false)}
      }
    end
    options
  end
end
