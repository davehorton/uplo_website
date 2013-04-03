class SharingMailer < ApplicationMailer
  helper GalleriesHelper

  def share_image_email(image_id, emails, user_id, message = nil)
    @message = message
    @user = User.unscoped.find(user_id)
    @image = Image.unscoped.find(image_id).decorate
    mail(:to => emails, :subject => "Shared Photo from UPLO")
  end

  def share_gallery_email(gallery_id, emails, user_id, message = nil)
    @message = message
    @user = User.unscoped.find(user_id)
    @gallery = GalleryDecorator.new(Gallery.unscoped.find(gallery_id))
    mail(:to => emails, :subject => "Shared Gallery from UPLO")
  end
end
