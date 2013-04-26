class GalleryInvitation < ActiveRecord::Base
  attr_accessible :email, :message

  validates :email, presence: true, format: { with: Devise.email_regexp }, uniqueness: { case_sensitive: false, message: 'is already associated with an invite.' }

  belongs_to :gallery

  before_create :set_secret_token

  def accept!
    self.update_attribute(:accepted, true)
  end

  private

  def set_secret_token
    begin
      self.secret_token = SecureRandom.hex(16)
    end until !GalleryInvitation.exists?(secret_token: secret_token)
  end

end
