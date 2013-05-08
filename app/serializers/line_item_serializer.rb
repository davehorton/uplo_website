class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :product, :quantity, :price, :image

  def image
    ImageSerializer.new(object.image, root: false)
  end

  def product
    prod = object.product
    {
      id:          prod.id,
      name:        "#{prod.size.to_name} - #{prod.moulding.name}",
      size_name:   prod.size.to_name,
      mould_name:  prod.moulding.name,
      price:       "%0.2f" % prod.price_for_tier(object.image.tier_id)
    }
  end
end
