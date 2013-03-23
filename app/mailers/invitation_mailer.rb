class InvitationMailer < ApplicationMailer
  def request_invitation(invitation_id)
    @inv = Invitation.find(invitation_id)
    mail(
      to: INVITE_REQUEST_EMAIL,
      subject: 'UPLO Request for Invite'
    )
  end

  def send_invitation(invitation_id)
    @inv = Invitation.find(invitation_id)
    mail(
      to: @inv.email,
      subject: 'UPLO Invitation'
    )
  end
end
