module GalleriesHelper
  def gallery_cover_image_url(gallery)
    img_url = "gallery-thumb-180.jpg" # Default image.
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
end
