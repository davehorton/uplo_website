source 'http://rubygems.org'

gem 'rails', '3.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem "unicorn" # HTTP Server
gem 'pg'
gem "will_paginate", ">= 3.0.pre4"
gem 'haml'
gem "haml-rails", ">= 0.3.4"
gem "inherited_resources", ">= 1.3.0"
gem "simple_form"
gem "awesome_print"
gem 'devise', '>= 1.5.3'
gem 'mail'

# If using HAML:
gem 'ruby_parser', '>= 2.3.1'
gem "hpricot", ">= 0.8.5"
gem "rails3-generators"
gem "paperclip", ">= 2.4.5"
gem "cancan", ">= 1.6.7"
gem "faker"
gem "rmagick"
gem "nested_form"
gem 'money'
gem "aws-s3"
gem "dalli" # For memcache
gem "nokogiri"

group :development do
  gem 'sqlite3'
  gem "mongrel", '1.2.0.pre2'
  gem "bullet"
  gem "pry"
  gem "heroku_san"
  gem "capistrano"
  gem "capistrano-ext", :require => "capistrano"
  
  if RUBY_VERSION >= "1.9"
    gem "ruby-debug19"
  else
    gem "ruby-debug"
  end
end

group :test do
  gem "factory_girl_rails"
  gem "machinist", "1.0.6"
  gem 'machinist_callbacks'
  gem "shoulda"
  gem "mynyml-redgreen", :require => "redgreen"
  gem "cucumber", ">= 1.1.4"
  gem "cucumber-rails", ">= 1.2.1"
  gem "capybara", ">= 1.1.2"
  gem "pickle", :git => "git://github.com/kb/pickle.git"
  gem "launchy", ">= 2.0.5"
  gem 'spork', '~> 0.9.0.rc'
  gem "rspec-rails", ">= 2.7.0"
end
