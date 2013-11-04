class UserMailer < ApplicationMailer
  def banned_user_email(user_id)
    @user = User.unscoped.find(user_id)
    mail(:to => @user.friendly_email, :subject => I18n.t("user_mailer.subject_banned_user"))
  end

  def removed_user_email(user_id)
    @user = User.unscoped.find(user_id)
    mail(:to => @user.friendly_email, :subject => I18n.t("user_mailer.subject_removed_user"))
  end

  def reinstated_user_email(user_id)
    @user = User.unscoped.find(user_id)
    mail(:to => @user.friendly_email, :subject => I18n.t("user_mailer.subject_reinstated_user"))
  end

  def flagged_image_email(user_id, image_id)
    @user = User.unscoped.find(user_id)
    @image = Image.unscoped.find(image_id)
    mail(:to => @user.friendly_email, :subject => I18n.t("user_mailer.subject_flagged_image"))
  end

  def flagged_image_removed_email(user_id, image_id = nil)
    @user = User.unscoped.find(user_id)

    if image_id
      @image = Image.unscoped.find(image_id)
      subject = I18n.t("user_mailer.subject_removed_image")
    else
      subject = I18n.t("user_mailer.subject_removed_images")
    end

    mail(:to => @user.friendly_email, :subject => subject)
  end

  def flagged_image_reinstated_email(user_id, image_id = nil)
    @user = User.unscoped.find(user_id)

    if image_id
      @image = Image.unscoped.find(image_id)
      subject = I18n.t("user_mailer.subject_reinstated_image")
    else
      subject = I18n.t("user_mailer.subject_reinstated_images")
    end

    mail(:to => @user.friendly_email, :subject => subject)
  end

  def deliver_welcome_email(user)
    mail(:to =>  user.email, :subject => "Welcome to UPLO!!")
  end

  def comment_notification_email_to_owner(comment)
    @owner, @comment, @author = comment.image.user, comment, comment.user
    mail(:to =>  @owner.email, :subject => "UPLO - Comment from #{@author.first_name}", :from => @author.friendly_email)
  end


  def comment_notification_email(receiver, comment, by_user)
    @comment, @author, @receiver = comment, by_user, receiver
    mail(:to =>  @receiver.email, :subject =>  "UPLO - Comment from #{@author.first_name}", :from => @author.friendly_email)
  end

end
