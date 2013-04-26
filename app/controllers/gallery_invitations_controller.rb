class GalleryInvitationsController < ApplicationController
  before_filter :get_gallery

  def index
    @gallery_invites = GalleryInvitation.all
  end

  def new
    @gallery_invitation = @gallery.gallery_invitations.new
  end

  def create
    @gallery_invitation = @gallery.gallery_invitations.new(params[:gallery_invitation])
    if @gallery_invitation.save
      flash[:success] = "An Invitation has been sent!"
      GalleryInvitationMailer.send_invitation(@gallery_invitation.id).deliver
      redirect_to gallery_gallery_invitations_path(@gallery)
    else
      flash[:error] = @gallery_invitation.errors.full_messages[0]
      render 'new'
    end
  end

  protected

  def get_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

end
