class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_file_name, :gallery_id,
             :price, :image_likes_count, :keyword, :owner_avatar, :gallery_cover, :tier_id,
             :image_url, :image_thumb_url, :username, :creation_timestamp, :user_fullname,
             :public_link, :user_id, :user_avatar, :comments_number, :gallery_name, :ordering_options

  def public_link
    object.decorate.public_link
  end

  def creation_timestamp
    object.decorate.creation_timestamp
  end

  def ordering_options
    options = []
    object.available_products.each do |product|
      options << { size_id: product.size_id, size: product.size.to_name, moulding_id: product.moulding_id, moulding: product.moulding.name, price: "%0.2f" % product.price_for_tier(object.tier_id), name: "#{product.moulding.name} - #{product.size.to_name}" }
    end
    { ordering_options: options }
  end
end
