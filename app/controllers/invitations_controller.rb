class InvitationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def create
    invitation = Invitation.new(params[:invitation])

    if invitation.save
      flash[:sticky_flash_message] = true
      flash[:success] = "Thanks for requesting an invite to UPLO! Once approved, we'll email you a signup link. And if you've already requested an invite and haven't heard back within a day or so, please check your spam folder."
      InvitationMailer.delay.request_invitation(invitation.id)
    else
      flash[:error] = invitation.errors.full_messages[0]
    end

    redirect_to root_path
  end
end
