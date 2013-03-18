class InvitationMailer < ApplicationMailer
  def send_invitation(invitation_id)
    @inv = Invitation.find(invitation_id)

    mail(
      to: @inv.email,
      subject: 'UPLO Invitation'
    )
  end
end
