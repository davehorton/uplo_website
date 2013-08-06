class ImageLikeObserver < ActiveRecord::Observer
  def after_create(image_like)

    Notification.deliver_image_notification(
      image_like.image_id,
      image_like.user_id,
      Notification::TYPE[:like]
    ) unless image_like.user.owns_image?(image_like.image)
  end
end
