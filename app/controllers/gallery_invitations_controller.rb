class GalleryInvitationsController < ApplicationController
  before_filter :get_gallery

  def index
    @gallery_invitations = @gallery.gallery_invitations
  end

  def new
    @gallery_invitation = @gallery.gallery_invitations.new
  end

  def create
    @gallery_invitation = @gallery.gallery_invitations.new(params[:gallery_invitation])
    error, @failed_list = GalleryInvitation.create_invitations(@gallery,
                                                 params[:gallery_invitation][:emails],
                                                 params[:gallery_invitation][:message]
                                                 )
    if error.blank?
      flash[:success] = "Successfully sent invitations!"
      redirect_to gallery_gallery_invitations_path(@gallery)
    else
      flash.now[:error] = error
      render 'new'
    end
  end

  protected

  def get_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

end
