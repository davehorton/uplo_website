class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :product, :product_option, :quantity, :price, :image

  def image
    ImageSerializer.new(object.image, root: false)
  end

  def product_option
    ProductOptionSerializer.new(object.product_option, root: false)
  end

  def product
    viewing_own_image = object.image.owner?(scope)

    prod = object.product
    {
      id:          prod.id,
      name:        "#{prod.size.to_name} - #{prod.moulding.name}",
      size_name:   prod.size.to_name,
      mould_name:  prod.moulding.name,
      price:       "%0.2f" % prod.price_for_tier(object.image.tier_id, viewing_own_image)
    }
  end
end
