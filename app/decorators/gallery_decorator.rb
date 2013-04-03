class GalleryDecorator < Draper::Decorator
  delegate_all

  def public_link
    h.public_gallery_url(source)
  end
end
