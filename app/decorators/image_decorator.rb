class ImageDecorator < Draper::Decorator
  delegate_all

  def public_link
    h.url_for controller: 'images',
              action:     'public',
              id:         source.id,
              only_path:  false,
              host:       DOMAIN
  end

  def creation_timestamp
    h.distance_of_time_in_words_to_now(source.created_at)
  end
end
