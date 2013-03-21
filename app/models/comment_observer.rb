class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    Notification.deliver_image_notification(
      comment.image_id,
      comment.user_id,
      Notification::TYPE[:comment]
    ) unless comment.user.owns_image?(comment.image)
  end
end
