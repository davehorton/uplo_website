class UserDevice < ActiveRecord::Base
  belongs_to :user

  validates :device_token, presence: true, uniqueness: true
  validates :user, presence: true
  validates :last_notified, presence: true

  def active?
    notify_purchases || notify_comments || notify_likes
  end
end
