source 'http://rubygems.org'
ruby '1.9.3'

gem 'dotenv-rails', :groups => [:development, :test]

# main stack
gem 'rails', '3.2.18'
gem 'pg', '~> 0.17.1'

# application components
gem 'activemerchant'
gem 'active_model_serializers', '~> 0.8.0'
gem 'active_utils'
gem 'alchemist'
gem 'aescrypt'
gem 'aws-sdk'
gem 'cancan'
gem 'classy_enum'
gem 'country-select'
gem 'dalli'
gem 'decent_exposure'
gem 'devise', '3.0.2'
gem 'draper'
gem 'email_reply_parser'
gem 'fb_graph'
gem 'flickraw'
gem 'gibbon'
gem 'haml', '~> 4.0.5'
gem 'highcharts-rails', '2.3.5'
gem 'honeybadger'
gem 'hpricot'
gem 'jquery-rails', '<3.0.0'
gem 'koala', '~> 1.7.0rc1'
gem 'money'
gem 'nested_form'
gem 'newrelic_rpm'
gem 'nifty-generators'
gem 'nokogiri'
gem 'oauth'
gem 'oauth2', '~> 0.6.0'
gem 'oj'
gem 'paperclip'
gem 'paperclip-dropbox', '~> 1.1.7'
gem 'paperclip-meta'
gem 'sidekiq', '~> 2.17.7'
gem 'sidekiq-failures'
gem 'simple_form'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'twitter'
gem 'urbanairship'
gem 'valid_email'
gem 'will_paginate', '~> 3.0'
gem 'omniauth'
gem 'omniauth-facebook', '1.4.0'
gem 'omniauth-twitter'

# for sidekiq admin
gem 'sinatra', require: false
gem 'slim'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier'
end

group :development, :test do
  gem 'factory_girl_rails', '~> 4.2'
  gem 'faker'
  gem 'rspec-rails', '~> 2.14.2'
end

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'thin'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rb-fsevent'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'simplecov', :require => false
end

group :staging, :production do
  gem 'ey_config'
  gem 'unicorn'
end
