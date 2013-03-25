# Welcome to UPLO

http://uplo.com

Historical note: we inherited this project from another shop in February 2013. We are currently maintaining and trying to get things in reasonable shape.

## Key Components

* Ruby 1.9.3
* Rails 3.2
* Postgresql (9.1+)

## Developer Setup

1. Install the above components and Redis
2. cp config/database.yml.example config/database.yml (update settings if needed)
3. bundle
4. bin/rake db:setup

## Testing

See https://github.com/webficient/standards/tree/master/testing for guidelines.

Observers are disabled in specs (see spec_helper) but have their own specific tests.

### Development Environment Gotchas

* We're using the 'letter opener' gem to intercept emails and display them in a Web browser

## Operations

### Engine Yard

* Unicorn is used in staging and production environments
* Amazon S3 credentials stored on server in /data/uplo_web/shared/config/amazon_s3.yml
* Add-ons:
 * SendGrid
* Custom Chef Recipes
 * Sidekiq
