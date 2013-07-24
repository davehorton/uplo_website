class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # remove existing invites
    Invitation.destroy_all(email: user.email)

    # subscribe to newsletter in production
    Rails.logger.debug user.email
    Rails.logger.debug user.first_name
    Rails.logger.debug user.last_name
    Rails.logger.debug user.to_yaml
    if !user.encrypted_password.blank?
      Mailchimp.delay.subscribe_user(use r.id) if Rails.env.production?
    end
  end
end
