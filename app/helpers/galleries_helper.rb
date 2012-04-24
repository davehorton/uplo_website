module GalleriesHelper
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
