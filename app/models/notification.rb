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

  def self.deliver_comment_notification(comment)
    by_user = comment.user
    receivers =  User.where(id: comment.image.comments.where("user_id != ?", by_user.id).pluck(:user_id).uniq).select { |u| u.device_tokens.present? }
    receivers.each do |receiver|
      notification = {
        :schedule_for => [30.second.from_now],
        :device_tokens => receiver.device_tokens,
        :aps => { :alert => "#{by_user.name_for_notification} also commented on image #{comment.image.name.humanize}" },
        :data => { :type => "commented_on", :id => comment.image_id.to_s }
      }
      Urbanairship.push(notification)
    end
  end

  def self.deliver_spotlight_notification(image, type)
    receiver = image.user
    if receiver.device_tokens.present?
      notification = {
        :schedule_for => [30.second.from_now],
        :device_tokens => receiver.device_tokens,
        :aps => { :alert => "Your image just made it to the Spotlight!" },
        :data => { :type => TYPE_ACTION[type].to_s, :id => image.id.to_s }
        }
      Urbanairship.push(notification)
    end
  end

  def self.deliver_follow_notification(user_follow, type)
    follower = User.find_by_id(user_follow.followed_by)
    receiver = user_follow.followed_user
    if receiver.device_tokens.present?
      notification = {
        :schedule_for => [30.second.from_now],
        :device_tokens => receiver.device_tokens,
        :aps => { :alert => "#{follower.name_for_notification} has just started following you" },
        :data => { :type => TYPE_ACTION[type].to_s, :id => follower.id.to_s }
      }
      Urbanairship.push(notification)
    end
  end

  def self.action(type, by_user)
    fullname = by_user.name_for_notification

    case type
      when TYPE[:like] then "#{fullname} likes your image"
      when TYPE[:comment] then "#{fullname} left you a comment!"
    else
      "You just made a sale!"
    end
  end

end
