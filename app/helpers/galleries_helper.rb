module GalleriesHelper
  def gallery_cover_image_url(gallery)
    img_url = "gallery-thumb-180.jpg" # Default image.
    image = gallery.cover_image
    if image
      img_url = image.url(:thumb)
    end
    
    return img_url
  end
end
