class CommentDecorator < Draper::Decorator
  delegate_all

  def duration
    h.distance_of_time_in_words_to_now(source.created_at)
  end

end
