class GalleryInvitationMailer < ActionMailer::Base
  default from: "from@example.com"

  def send_invitation(invitation_id)
    @gallery_invitation = GalleryInvitation.find(invitation_id)
    mail(
         to: @gallery_invitation.email,
         subject: 'UPLO Invite to Gallery'
         )
  end

end
