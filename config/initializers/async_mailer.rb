#TODO: replace with sidekiq-based email process

# Adds :async_smtp delivery methods to perform email deliveries asynchronously
module AsyncMailer
  class AsyncSmtp < Mail::SMTP
    def initialize(values)
      super(values)
    end

    def deliver!(mail)
      Thread.start do
        super(mail)
      end
    end
  end
end

ActionMailer::Base.add_delivery_method :async_smtp, AsyncMailer::AsyncSmtp,
  Rails.application.config.action_mailer.smtp_settings
