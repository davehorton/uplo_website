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
        gal.name = "#{gal.name.truncate(18)} (#{gal.images.unflagged.size})"
      else
        gal.name = gal.name.truncate(25)
      end
    }
    return options_from_collection_for_select(collection, 'id', 'name', selected)
  end

  def gallery_cover_image_url(gallery)
    img_url = "#{root_url}/assets/gallery-thumb-180.jpg" # Default image.
    image = gallery.cover_image
    if image && !image.removed? && (!image.flagged?)
      img_url = image.url(:thumb)
    end

    return img_url
  end

  def gallery_price_options
    options_for_select([["Standard", "20"], ['Other', '10']])
  end

  def can_modify_gallery?(gallery, user = nil)
    user ||= current_user
    user.owns_gallery?(gallery)
  end
end
