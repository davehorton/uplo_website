class ImageDecorator < Draper::Decorator
  delegate_all

  def public_link
    h.url_for controller: 'images',
              action:     'public',
              id:         source.id,
              only_path:  false,
              host:       DOMAIN
  end
end
