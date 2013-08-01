class UserFollowObserver < ActiveRecord::Observer
  def after_create(user_follow)
          Rails.logger.debug user_follow.inspect

    Notification.deliver_follow_notification(
      user_follow,
      Notification::TYPE[:follow]
    ) 
  end
end
