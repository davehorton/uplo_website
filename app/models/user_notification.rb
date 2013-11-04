class UserNotification < ActiveRecord::Base
  attr_accessible :user_id, :push_like, :push_comment, :push_purchase, :push_follow, :push_spotlight, :comment_email

  belongs_to :user

  validates_presence_of :user_id
end
