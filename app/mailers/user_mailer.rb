class UserMailer < ApplicationMailer
  def banned_user_email(user)
    @user = user
    subject = I18n.t("user_mailer.subject_banned_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end

  def removed_user_email(user)
    @user = user
    subject = I18n.t("user_mailer.subject_removed_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end

  def reinstated_user_email(user)
    @user = user
    subject = I18n.t("user_mailer.subject_reinstated_user")
    mail(:to => @user.friendly_email, :subject => subject)
  end

  def flagged_image_email(user, image)
    @user = user
    @image = image
    subject = I18n.t("user_mailer.subject_flagged_image")
    mail(:to => @user.friendly_email, :subject => subject)
  end

  def flagged_image_removed_email(user_id, image = nil)
    @user = User.find(user_id)

    if image.blank?
      subject = I18n.t("user_mailer.subject_removed_images")
    else
      @image = image
      subject = I18n.t("user_mailer.subject_removed_image")
    end

    mail(:to => @user.friendly_email, :subject => subject)
  end

  def flagged_image_reinstated_email(user_id, image = nil)
    @user = User.find(user_id)

    if image.blank?
      subject = I18n.t("user_mailer.subject_reinstated_images")
    else
      @image = image
      subject = I18n.t("user_mailer.subject_reinstated_image")
    end

    mail(:to => @user.friendly_email, :subject => subject)
  end
end
