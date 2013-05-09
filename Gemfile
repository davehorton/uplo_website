source 'http://rubygems.org'
ruby '1.9.3'

# main stack
gem 'rails', '3.2.13'
gem 'pg'

# application components
gem 'activemerchant'
gem 'active_model_serializers', '~> 0.7.0'
gem 'active_utils'
gem 'alchemist'
gem 'aescrypt'
gem 'aws-sdk', '~> 1.5.7'
gem 'cancan'
gem 'classy_enum'
gem 'country-select'
gem 'dalli'
gem 'decent_exposure'
gem 'devise'
gem 'draper'
gem 'fb_graph'
gem 'flickraw'
gem 'gibbon'
gem 'haml-rails', '0.3.5'
gem 'highcharts-rails', '2.3.5'
gem 'honeybadger'
gem 'jquery-rails'
gem 'jquery-fileupload-rails'
gem 'hpricot'
gem 'money'
gem 'nested_form'
gem 'nokogiri'
gem 'oauth'
gem 'oauth2'
gem 'oj'
gem 'paperclip'
gem 'paperclip-dropbox'
gem 'paperclip-meta'
gem 'sidekiq'
gem 'simple_form'
gem 'textacular', '~> 3.0', require: 'textacular/rails'
gem 'twitter'
gem 'urbanairship'
gem 'valid_email'
gem 'will_paginate', '~> 3.0'

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
  gem 'rspec-rails', '~> 2.13'
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
  gem 'guard'
  gem 'guard-spork'
  gem 'launchy'
  gem 'rb-fsevent'
  gem 'rspec-nc'
  gem 'selenium-webdriver'
  gem 'spork-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'simplecov', :require => false
end

group :staging, :production do
  gem 'ey_config'
  gem 'unicorn'
end