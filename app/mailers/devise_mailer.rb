class DeviseMailer < ApplicationMailer
  def send_confirmation_email(user)
    @user = user
    mail_params = {
      :to => @user[:email],
      :subject => t('devise.mailer.confirmation_instructions.subject')
    }

    mail(mail_params)
  end
end
