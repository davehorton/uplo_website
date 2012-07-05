class UserDevice < ActiveRecord::Base
  # Validations
  validates_presence_of :device_token, :user_id, :last_notified, :message => 'cannot be blank'
  validates_uniqueness_of :device_token, :message => 'must be unique'

  # Associations
  belongs_to :user

end
