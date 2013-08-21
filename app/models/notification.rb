class Notification < ActiveRecord::Base
  TYPE = {
    :like => 0,
    :comment => 1,
    :purchase => 2,
    :follow => 3
  }

  TYPE_ACTION = {
    TYPE[:like] => 'like',
    TYPE[:follow] => 'follow',
    TYPE[:spotlight] => 'spotlight',
    TYPE[:followspotlight] => 'followspotlight',
    TYPE[:comment] => 'commented on',
    TYPE[:purchase] => 'purchased'
  }

  def self.deliver_image_notification(image_id, by_user_id, type)
    image = Image.find_by_id(image_id)

    if image
      by_user = User.find_by_id(by_user_id)
      receiver = image.user

      if by_user && receiver && receiver.device_tokens.present?

        message = Notification.action(type, by_user)

        notification = {
          :schedule_for => [30.second.from_now],
          :device_tokens => receiver.device_tokens,
          :aps => { :alert => message },
          :data => { :type => TYPE_ACTION[type].to_s, :id => image.id.to_s }
        }
        Urbanairship.push(notification)
      end
    end
  end

  def self.deliver_spotlight_notification(image, type)
    receiver = image.user

    if receiver.device_tokens.present?

      message = "Your image just made it to the Spotlight!"

      notification = {
        :schedule_for => [30.second.from_now],
        :device_tokens => receiver.device_tokens,
        :aps => { :alert => message },
        :data => { :type => TYPE_ACTION[type].to_s, :id => image.id.to_s }
        }
      Urbanairship.push(notification)
    end
  end

  def self.deliver_follow_notification(user_follow, type)
    follower = User.find_by_id(user_follow.followed_by)
    receiver = user_follow.followed_user

    if receiver.device_tokens.present?

      if follower.admin?
        message = "UPLO has just started following you"
      else
        message = "#{follower.username} has just started following you"
      end

      notification = {
        :schedule_for => [30.second.from_now],
        :device_tokens => receiver.device_tokens,
        :aps => { :alert => message },
        :data => { :type => TYPE_ACTION[type].to_s, :id => follower.id.to_s }
      }
      Urbanairship.push(notification)
    end
  end

  def self.action(type, by_user)
    if by_user.admin?
      fullname = "UPLO"
    else
      fullname = by_user.fullname
    end

    case type
      when TYPE[:like] then "#{fullname} likes your image"
      when TYPE[:comment] then "#{fullname} left you a comment!"
    else
      "You just made a sale!"
    end
  end

end
