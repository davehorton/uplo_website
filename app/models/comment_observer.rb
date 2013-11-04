class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    if !comment.user.owns_image?(comment.image) && comment.image.user.notify?(:comment_email)
      Notification.deliver_image_notification(comment.image_id, comment.user_id, Notification::TYPE[:comment])
      UserMailer.delay.comment_notification_email_to_owner(comment)
    end
    Notification.deliver_comment_notification(comment)
  end
end
