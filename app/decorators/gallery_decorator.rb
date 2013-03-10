class GalleryDecorator < Draper::Decorator
  delegate_all

  def public_link
    h.url_for controller: 'galleries',
              action:     'public',
              gallery_id: source.id,
              only_path:  false,
              host:       DOMAIN
  end
end
