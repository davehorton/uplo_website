class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # remove existing invites
    Invitation.destroy_all(email: user.email)

    # subscribe to newsletter in production
    # Mailchimp.delay.subscribe_user(user.id) if Rails.env.production?
  end
end
