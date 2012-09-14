source 'http://rubygems.org'

gem 'rails', '>= 3.1.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'iron_worker'
# gem 'typhoeus'

# Social network
gem 'twitter'
gem 'flickraw'
gem 'urbanairship'

#gem "unicorn" # HTTP Server
gem 'pg'
gem "will_paginate", ">= 3.0.pre4"
gem 'haml'
gem 'json'
gem "haml-rails", ">= 0.3.4"
gem "inherited_resources", ">= 1.3.0"
gem "simple_form"
gem "awesome_print"
gem 'devise', '~> 1.5.3'
gem 'mail'
gem 'mobile-fu'
gem 'rufus-scheduler'

# If using HAML:
gem 'ruby_parser', '>= 2.3.1'
gem "hpricot", ">= 0.8.5"
gem "rails3-generators"
gem "paperclip", "3.0.4"
gem "cancan", ">= 1.6.7"
gem "faker"
gem "rmagick"
gem "nested_form"
gem "aws-s3", :require => "aws/s3"
gem "aws-sdk", '~> 1.3.4'
gem "dalli" # For memcache
gem "nokogiri"
gem 'country-select'

# Social Integration
gem 'oauth2'

# Validate Email
gem 'valid_email'

# AES Crypt
gem 'aescrypt'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'yui-compressor', '>= 0.9.6'
end

#gem 'jquery-rails'
gem 'thinking-sphinx', '>= 2.0.10'
gem 'flying-sphinx',   '>= 0.6.2'

# ECommerce
gem 'activemerchant', '>= 1.20.1'
gem 'active_utils'
gem 'authorize-net', '>= 1.5.2'
gem 'money'

group :development do
#  gem 'thin'
#  gem 'typhoeus'
  gem 'execjs'
  gem 'therubyracer'
  gem 'sqlite3'
  gem "mongrel", '1.2.0.pre2'
  gem "bullet"
  gem "pry"
  gem "heroku_san"
  #gem "capistrano"
  #gem "capistrano-ext", :require => "capistrano"
  gem "guard-sass"
  gem "guard-coffeescript"
  gem 'taps'

  if RUBY_VERSION >= "1.9"
    gem "ruby-debug19"
  else
    gem "ruby-debug"
  end
end

group :test do
  gem 'database_cleaner', '>= 0.7.0'
  gem "factory_girl_rails", '>= 1.5.0'
  gem 'sham', '>= 1.0.2'
  gem "machinist", ">= 2.0"
  gem "shoulda"
  gem "mynyml-redgreen", :require => "redgreen"
  gem "cucumber", ">= 1.1.4"
  gem "cucumber-rails", ">= 1.2.1"
  gem "capybara", ">= 1.1.2"
  gem "pickle"
  gem "launchy", ">= 2.0.5"
  gem 'spork', '~> 0.9.0.rc'
  gem "rspec-rails", ">= 2.8.1"
end
