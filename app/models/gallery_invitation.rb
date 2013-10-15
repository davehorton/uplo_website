class GalleryInvitation < ActiveRecord::Base
  attr_accessible :emails, :message, :gallery_id, :secret_token, :user_id

  validates :emails, presence: true, format: { with: Devise.email_regexp }
  validates :gallery_id, presence: true

  belongs_to :gallery
  belongs_to :user

  before_create :set_secret_token

  def self.create_invitations(gallery, emails, message)
    return "Please enter emails" if emails.blank?
    return "Please provide a message" if message.blank?
    failed_list = []
    emails.split(/[\s,]+/).each do |email|
      gallery_invitation = gallery.gallery_invitations.where(emails: email.squish).first_or_initialize(message: message)
      if gallery_invitation.save
        GalleryInvitationMailer.delay.send_invitation(gallery_invitation.id)
      else
        failed_list << email
      end
    end
    error = "Could not send invitation to the following emails." if failed_list.present?
    [error, failed_list]
  end

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
