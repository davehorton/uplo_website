class UserMailer < ApplicationMailer
  def user_is_banned(user)
    @user = user
    subject = I18n.t("user_mailer.subject_banned_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end
  
  def user_is_removed(user)
    @user = user
    subject = I18n.t("user_mailer.subject_removed_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end
  
  def user_is_reinstated(user)
    @user = user
    subject = I18n.t("user_mailer.subject_reinstated_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end
  
end
