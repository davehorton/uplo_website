module GalleriesHelper
  MOULDING_DISPLAY = {
    Image::MOULDING[:print] => 'Print Only',
    Image::MOULDING[:canvas] => 'Canvas',
    Image::MOULDING[:plexi] => 'Plexi',
    Image::MOULDING[:black] => 'Black',
    Image::MOULDING[:white] => 'White',
    Image::MOULDING[:light_wood] => 'Light Wood',
    Image::MOULDING[:rustic_wood] => 'Rustic Wood'
  }

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

  def printed_sizes_options(image, selected = nil)
    options = []
    image.printed_sizes.each do |size|
      options << ["#{size} ($#{ image.get_price(image.tier, size)})", size, {'data-url' => image.data.url("scale#{size}")}]
    end
    options_for_select(options, selected)
  end

  def mounding_options(selected = nil)
    options = []
    Image::MOULDING.each do |k, v|
      discount = Image::MOULDING_DISCOUNT[v]
      if discount == 0
        options << [MOULDING_DISPLAY[v], v]
      else
        options << ["#{MOULDING_DISPLAY[v]} (#{discount * 100}% Off)", v]
      end
    end
    options_for_select(options, selected)
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
    [Gallery::PUBLIC_PERMISSION, Gallery::PRIVATE_PERMISSION].each do |permission|
      result << [I18n.t("gallery.permission")[permission], permission]
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
