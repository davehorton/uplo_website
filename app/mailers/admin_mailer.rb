class AdminMailer < ApplicationMailer
  default :to => ADMIN_EMAIL

  def missing_product(image_id)
    @image = Image.custom_find(image_id)
    mail(subject: '[UPLO] Missing product options')
  end
end