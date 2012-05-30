module GalleriesHelper
  def gallery_options(user_id, image_id = nil)
    user = User.find_by_id user_id
    if image_id.nil?
      image = user.images.first
    else
      image = Image.find_by_id image_id
    end
    selected = image.gallery_id
    collection = user.galleries
    return options_from_collection_for_select(collection, 'id', 'name', selected)
  end

  def gallery_cover_image_url(gallery)
    img_url = "/assets/gallery-thumb-180.jpg" # Default image.
    image = gallery.cover_image
    if image
      img_url = image.url(:thumb)
    end

    return img_url
  end

  def gallery_permissions_options
    result = []
    [:public, :protected].each do |permission|
      result << [I18n.t("gallery.permission.#{permission}"), permission]
    end
    result
  end

  def can_modify_gallery?(gallery, user = nil)
    user ||= current_user
    return gallery.is_owner?(user)
  end
end
