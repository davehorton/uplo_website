class SharingMailer < ApplicationMailer
  helper GalleriesHelper

  def share_image_email(image_id, emails, user_id, message = nil)
    @message = message
    @user = User.find(user_id)
    @image = Image.find(image_id)
    begin
      mail(:to => emails, :subject => "Shared Photo from UPLO")
    rescue
      return false
    end
  end

  def share_gallery_email(gallery_id, emails, user_id, message = nil)
    @message = message
    @user = User.find(user_id)
    @gallery = GalleryDecorator.find(gallery_id)
    mail(:to => emails, :subject => "Shared Gallery from UPLO")
  end
end
