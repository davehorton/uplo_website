# == Schema Information
#
# Table name: user_follows
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  followed_by :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

class UserFollow < ActiveRecord::Base
  belongs_to :followed_user, :foreign_key => :user_id, :class_name => 'User'
  belongs_to :follower, :foreign_key => :followed_by, :class_name => 'User'
end
