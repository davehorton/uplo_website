class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :biography, :facebook_enabled, :twitter_enabled, :location,
             :paypal_email, :website, :job, :last_name, :username, :nationality, :birthday, :gender,
             :twitter, :facebook, :avatar_url, :fullname, :joined_date, :billing_address, :shipping_address,
             :confirmed_at, :galleries_num, :images_num, :followers_num, :following_num, :cart_items_num

  def galleries_num
    if object == current_user
      object.galleries.size
    else
      object.public_galleries.size
    end
  end

  def images_num
    if object == current_user
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
    if object == current_user && object.cart.try(:order)
      object.cart.order.line_items.count
    end
  end
end
