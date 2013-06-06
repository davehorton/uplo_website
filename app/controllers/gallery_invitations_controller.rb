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
    if params[:gallery_invitation][:emails].present?
      params[:gallery_invitation][:emails].split(',').each do |email|
        @gallery_invitation = @gallery.gallery_invitations.where(emails: email.squish).first_or_create!(message: params[:gallery_invitation][:message])
        flash[:success] = "An Invitation has been sent!"
        GalleryInvitationMailer.delay.send_invitation(@gallery_invitation.id)
      end
      redirect_to gallery_gallery_invitations_path(@gallery)
    else
      flash[:error] = 'Please enter one email'
      render 'new'
    end
  end

  protected

  def get_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

end
