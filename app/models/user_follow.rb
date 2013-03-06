class UserFollow < ActiveRecord::Base
  belongs_to :followed_user, :foreign_key => :user_id, :class_name => 'User'
  belongs_to :follower, :foreign_key => :followed_by, :class_name => 'User'
end
