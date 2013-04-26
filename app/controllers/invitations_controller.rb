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

  def accept_gallery_invitation
    @inv = GalleryInvitation.find_by_secret_token params[:secret_token]
    user = User.find_by_email(@inv.email)
    session[:user_return_to] =  gallery_images_path(@inv.gallery)
    if user
      @inv.update_attribute(:user_id, user.id)
      redirect_to new_user_session_path(:id => @inv.id)
    else
      redirect_to new_user_registration_path(:id => @inv.id)
    end
  end

end
