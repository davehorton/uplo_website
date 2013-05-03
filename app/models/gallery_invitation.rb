class GalleryInvitation < ActiveRecord::Base
  attr_accessible :email, :message, :gallery_id, :secret_token, :user_id

  validates :email, presence: true, format: { with: Devise.email_regexp }, uniqueness: { case_sensitive: false, message: 'is already associated with an invite.', :scope => [:gallery_id] }
  validates :gallery_id, presence: true

  belongs_to :gallery
  belongs_to :user

  before_create :set_secret_token

  def accepted?
    self.user_id.present?
  end

  private

  def set_secret_token
    begin
      self.secret_token = SecureRandom.hex(16)
    end until !GalleryInvitation.exists?(secret_token: secret_token)
  end

end
