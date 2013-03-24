class ImageDecorator < Draper::Decorator
  delegate_all

  def public_link
    h.public_image_url(source)
  end

  def creation_timestamp
    h.distance_of_time_in_words_to_now(source.created_at)
  end
end
