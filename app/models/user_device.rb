# == Schema Information
#
# Table name: user_devices
#
#  id               :integer          not null, primary key
#  device_token     :string(255)      not null
#  user_id          :integer          not null
#  notify_comments  :boolean          default(TRUE)
#  notify_likes     :boolean          default(TRUE)
#  notify_purchases :boolean          default(TRUE)
#  last_notified    :datetime         not null
#  created_at       :datetime
#  updated_at       :datetime
#

class UserDevice < ActiveRecord::Base
  # Validations
  validates_presence_of :device_token, :user_id, :last_notified, :message => 'cannot be blank'
  validates_uniqueness_of :device_token, :message => 'must be unique'

  # Associations
  belongs_to :user

  def is_active
  	self.notify_purchases || self.notify_comments || self.notify_likes
  end

end
