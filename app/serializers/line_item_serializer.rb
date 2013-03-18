class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :moulding, :size, :quantity, :price, :image_name, :image_id,
             :image_thumb_url, :image_name, :image_url
end
