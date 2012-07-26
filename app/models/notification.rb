class Notification < ActiveRecord::Base
  TYPE = {
    :like => 0,
    :comment => 1,
    :purchase => 2
  }
  TYPE_ACTION = {
    TYPE[:like] => 'like',
    TYPE[:comment] => 'commented',
    TYPE[:purchase] => 'purchased'
  }

  def self.deliver_image_notification(image_id, by_user, type)
    image = Image.find_by_id image_id.to_i
    if image
      by_user = User.find_by_id by_user.to_i
      if image.author && by_user && UserDevice.exists?({:user_id => image.author.id.to_i})
        tokens = []
        image.author.devices.each do |d|
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

  def self.check_others(image_id)
    image = Image.find_by_id image_id.to_i
    others_count = image.image_likes.count - 1
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
