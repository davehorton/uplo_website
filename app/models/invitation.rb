class Invitation < ActiveRecord::Base
  include ::Shared::QueryMethods

  before_validation :strip_email
  validates :email, presence: true, format: { with: Devise.email_regexp }, uniqueness: { case_sensitive: false }

  before_create :set_token

  default_scope order('created_at desc')
  scope :requested, where(invited_at: nil)

  def invite!
    touch(:invited_at)
    notify_observers(:after_invite)
  end

  private

    def strip_email
      self.email = self[:email].try(:strip)
    end

    def set_token
      begin
        self.token = SecureRandom.hex(16)
      end until !Invitation.exists?(token: token)
    end
end

