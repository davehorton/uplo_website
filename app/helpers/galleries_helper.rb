module GalleriesHelper
  def gallery_options(user_id, selected_gallery = nil, size_necessary = false)
    user = User.find_by_id user_id
    collection = user.galleries
    if collection.size == 0
      selected = nil
    elsif selected_gallery.nil?
      selected = collection[0].id
    else
      selected = selected_gallery
    end
    collection.map { |gal|
      if size_necessary
        gal.name = "#{gal.name.truncate(18)} (#{gal.images.un_flagged.size})"
        # gal.name = "<div class='clearfix'><span class='left'>#{gal.name.truncate(18)}</span>
        #   <span class='number text fuzzy-gray left'>(#{gal.images.size})</span></div>"
      else
        gal.name = gal.name.truncate(25)
      end
    }
    return options_from_collection_for_select(collection, 'id', 'name', selected)
  end

  def gallery_cover_image_url(gallery)
    img_url = "/assets/gallery-thumb-180.jpg" # Default image.
    image = gallery.cover_image
    if image && !image.is_removed? && (!image.is_flagged?)
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

  def gallery_price_options
    options_for_select([["Standard", "20"], ['Other', '10']])
  end

  def can_modify_gallery?(gallery, user = nil)
    user ||= current_user
    return gallery.is_owner?(user)
  end
end
