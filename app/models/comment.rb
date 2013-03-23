class Comment < ActiveRecord::Base
  include ::Shared::QueryMethods

  belongs_to :image
  belongs_to :user
  belongs_to :active_user, class_name: 'User', foreign_key: 'user_id', conditions: { banned: false, removed: false }

  validates_presence_of :image, :user, :description

  default_scope order('comments.created_at desc')
  scope :available, joins(:active_user)

  alias_attribute :commenter_id, :user_id

  def commenter
    user.username
  end

  def commenter_avatar(size='large')
    user.avatar_url(size)
  end
end
