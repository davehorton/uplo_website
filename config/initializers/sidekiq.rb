class Sidekiq::Extensions::DelayedMailer
  sidekiq_options retry: 3
end

class Sidekiq::Extensions::DelayedClass
  sidekiq_options retry: false
end

Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}" }
end if Rails.env.production?

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}" }
end if Rails.env.production?
