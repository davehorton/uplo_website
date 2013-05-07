class GalleryInvitationMailer < ActionMailer::Base

  def send_invitation(invitation_id)
    @gallery_invitation = GalleryInvitation.find(invitation_id)
    mail(
      to: @gallery_invitation.email,
      subject: 'UPLO Invite to Gallery',
      from: @gallery_invitation.gallery.user.friendly_email
    )
  end
end
