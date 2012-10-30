class DeviseMailer < ApplicationMailer
  def send_confirmation_email(user)
    @user = user
    mail_params = {
      :to => @user[:email],
      :subject => 'UPLO Invitation'
    }

    mail(mail_params)
  end
end
