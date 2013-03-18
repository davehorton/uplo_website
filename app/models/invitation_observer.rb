class InvitationObserver < ActiveRecord::Observer
  def after_invite(invitation)
    InvitationMailer.delay.send_invitation(invitation.id)
  end
end
