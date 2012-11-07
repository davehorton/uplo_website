class PaymentMailer < ApplicationMailer
  def transaction_finish(order)
    subject = I18n.t("order.email.transaction_finish_subject")
    @user = order.user
    mail_params = {
      :to => @user.friendly_email,
      :subject => subject
    }
    
    mail(mail_params)
  end

  def inform_new_order(order)
    subject = I18n.t("order.email.inform_new_order")
    @user = order.user
    @order = order
    mail_params = {
      :to => "uplo@digital2media.com",
      :subject => subject
    }
    
    mail(mail_params)
  end
end
