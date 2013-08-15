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

  def self.deliver_image_notification(image_id, by_user, type)

    image = Image.find_by_id image_id.to_i

    if image
      by_user = User.find_by_id by_user.to_i

      Rails.logger.debug "rtyrty"
      Rails.logger.debug UserDevice.exists?(user_id: image.user_id)

      if image.user && by_user && UserDevice.exists?(user_id: image.user_id)
        tokens = []

        image.user.devices.each do |d|
          tokens << d.device_token
        end

        message = "#{by_user.fullname}#{Notification.check_others(image_id)}#{Notification.action(image_id, type)} your image"

        notification = {
          :schedule_for => [30.second.from_now],
          :device_tokens => tokens,
          :aps => { :alert => message },
          :data => { :type => TYPE_ACTION[type].to_s, :id => image.id.to_s }
        }

        Urbanairship.push(notification)
      end
    end
  end

  def self.deliver_spotlight_notification(image, type)
    # image = User.find_by_id image.user_id

    if image
      if UserDevice.exists?(user_id: image.user_id)
		    device = UserDevice.find_by_user_id image.user_id

        tokens = []
		    tokens << device.device_token

        message = "Your image was just added to the Spotlight"

        notification = {
          :schedule_for => [30.second.from_now],
          :device_tokens => tokens,
          :aps => { :alert => message },
          :data => { :type => TYPE_ACTION[type].to_s, :id => image.id.to_s }
        }

        Urbanairship.push(notification)
      end
    end
  end

  def self.deliver_follow_notification(user_follow, type)
    follower = User.find_by_id user_follow.followed_by

    if follower
      if UserDevice.exists?(user_id: user_follow.user_id)
		    device = UserDevice.find_by_user_id user_follow.user_id

        tokens = []
		    tokens << device.device_token

        message = "#{follower.username} has just added you as a friend"

        notification = {
          :schedule_for => [30.second.from_now],
          :device_tokens => tokens,
          :aps => { :alert => message },
          :data => { :type => TYPE_ACTION[type].to_s, :id => follower.id.to_s }
        }

        Urbanairship.push(notification)
      end
    end
  end

  def self.check_others(image_id)
    image = Image.find_by_id image_id.to_i
    others_count = image.image_likes.size - 1

    if others_count > 1
      msg = " and #{others_count} others "
    elsif others_count == 1
      msg = " and #{others_count} other "
    else
      msg = ' '
    end

    return msg
  end

  def self.action(image_id, type)
    image = Image.find_by_id image_id.to_i

    if type != TYPE[:like]
      msg = " #{TYPE_ACTION[type]}"
    elsif image.image_likes.count > 1
      msg = " #{TYPE_ACTION[type]}"
    else
      msg = " #{TYPE_ACTION[type]}s"
    end

    return msg
  end

end
