class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :biography, :facebook_enabled, :twitter_enabled, :location,
             :website, :job, :last_name, :username, :birthday, :gender,
             :twitter, :facebook, :avatar_url, :fullname, :joined_date, :galleries_num, :images_num, :followers_num, :following_num, :followed_by_current_user, :cart_items_num

  def attributes
    hash = super
    if object == scope
      hash["email"] = object.email
      hash["paypal_email"] = object.paypal_email
      hash["billing_address"] = object.billing_address
      hash["shipping_address"] = object.shipping_address
      hash["confirmed_at"] = object.confirmed_at
    end
    hash
  end

  def galleries_num
    if object == scope
      object.galleries.size
    else
      object.public_galleries.size
    end
  end

  def images_num
    if object == scope
      object.images.unflagged.size
    else
      object.images.public_access.size
    end
  end

  def followers_num
    object.followers.size
  end

  def following_num
    object.followed_users.size
  end

  def cart_items_num
    if object == scope && object.cart.try(:order)
      object.cart.order.line_items.count
    end
  end

  def followed_by_current_user
    object.has_follower?(scope.try(:id))
  end
end
