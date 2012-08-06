class InvitationMailer < ApplicationMailer
  def send_invitation(inv_id, msg = '')
    @inv = Invitation.find_by_id inv_id
    @msg = msg
    mail_params = {
      :to => @inv.email,
      :subject => 'UPLO Invitation'
    }

    mail(mail_params)
  end
end
