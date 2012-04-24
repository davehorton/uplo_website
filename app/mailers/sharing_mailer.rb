class SharingMailer < ApplicationMailer
  helper GalleriesHelper

  def share_image_email(image_id, emails)
    @user = User.first
    @image = Image.find_by_id image_id
    mail(:to => emails, :subject => "Share from UPLO")
  end

  def share_gallery_email(gallery_id, emails)
    @user = User.first
    @gallery = Gallery.find_by_id gallery_id
    mail(:to => emails, :subject => "Share from UPLO")
  end
end
