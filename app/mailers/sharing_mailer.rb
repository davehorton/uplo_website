class SharingMailer < ApplicationMailer
  helper GalleriesHelper

  def share_image_email(image_id, emails, user_id, message = nil)
    @message = message
    @user = User.find_by_id user_id
    @image = Image.find_by_id image_id
    begin
      mail(:to => emails, :subject => "Share from UPLO")
    rescue
      return false
    end
  end

  def share_gallery_email(gallery_id, emails, user_id, message = nil)
    @message = message
    @user = User.find_by_id user_id
    @gallery = Gallery.find_by_id gallery_id
    mail(:to => emails, :subject => "Share from UPLO")
  end
end
