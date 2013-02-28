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

See https://github.com/webficient/standards/tree/master/testing

## Operations

### Heroku

* Staging and Production environments
* Add-ons:
 * Redis to Go