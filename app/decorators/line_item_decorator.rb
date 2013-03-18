class LineItemDecorator < Draper::Decorator
  delegate_all

  def creation_timestamp
    h.distance_of_time_in_words_to_now(source.created_at)
  end

end
