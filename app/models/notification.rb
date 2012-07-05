class Notification < ActiveRecord::Base
  TYPE = {
    :like => 0,
    :comment => 1,
    :purchase => 2
  }
  TYPE_ACTION = {
    TYPE[:like] => 'like',
    TYPE[:comment] => 'comment',
    TYPE[:purchase] => 'purchase'
  }

  def self.deliver_image_notification(image_id, by_user, type)
    image = Image.find_by_id image_id.to_i
    if image
      by_user = User.find_by_id by_user.to_i
      if image.author && by_user && UserDevice.exists?({:user_id => image.author.to_i})
        tokens = []
        user.devices.each do |d|
          tokens << d.device_tokens
        end

        message = "#{by_user.fullname}#{check_others(image_id)}#{action(image_id, type)} your image"
        notification = {
          :schedule_for => [3.minute.from_now],
          :device_tokens => tokens,
          :aps => { :alert => message },
          :data => { :image => image.serializable_hash(image.default_serializable_options) }
        }
        Urbanairship.push(notification)
      end
    end
  end

  protected
    def check_others(image_id)
      image = Image.find_by_id image_id.to_i
      others_count = image.image_likes.count
      if others_count > 1
        msg = " and #{others_count}"
      else
        msg = ' '
      end
      return msg
    end
    def action(image_id, type)
      image = Image.find_by_id image_id.to_i
      if image.image_likes.count > 1
        msg = " #{TYPE_ACTION[type]}"
      else
        msg = " #{TYPE_ACTION[type]}s"
      end
      return msg
    end
end
