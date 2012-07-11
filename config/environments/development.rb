Uplo::Application.configure do
  DOMAIN = '192.168.7.71:3000'
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # The line of code below will prevent loading files from /public/assets"
  config.serve_static_assets = false

  # Bullet config
  config.after_initialize do
    Bullet.enable                = false
    Bullet.alert                 = true
    Bullet.bullet_logger         = true
    Bullet.console               = true
    Bullet.rails_logger          = true
    Bullet.disable_browser_cache = true
  end

  config.action_mailer.default_url_options = { :host => DOMAIN }
  config.action_mailer.delivery_method = :smtp

  # GMAIL
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'gmail.com',
    :user_name            => 'uplo.mailer',
    :password             => 'uploTPL123456',
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

end

ENV['IRON_WORKER_TOKEN'] = 'syi1brYtdyKSHphY8OjuA4QjW_8'
ENV['IRON_WORKER_PROJECT_ID'] = '4f66dfe48de4561d190044ab'
