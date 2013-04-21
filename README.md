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
3. Setup other config files (see config/*.yml.sample)
4. bundle
5. bin/rake db:setup

## Testing

See https://github.com/webficient/standards/tree/master/testing for guidelines.

Observers are disabled in specs (see spec_helper) but have their own specific tests.

## Development Environment Notes

### Emails

We are using the 'letter opener' gem to intercept emails and display them in a Web browser

### Image Renditions

We are using Sidekiq to process images via the delayed_paperclip gem. Therefore to run the Sidekiq locally to process the queue, do this:

```
bundle exec sidekiq -q default -q paperclip
```

To view the Sidekiq dashboard, go to http://locahost:3000/sidekiq

To purge Sidekiq jobs, open up the Redis client:

```
redis-cli
```

And type: FLUSHALL

#### Rebuilding Image Metadata

To rebuild images metadata locally, be sure Sidekiq is running and run the following Paperclip task:

```
bundle exec rake paperclip:refresh:metadata CLASS=Image
```

## Operations

### Engine Yard

* Unicorn is used in staging and production environments
* Amazon S3 credentials stored on server in /data/uplo_web/shared/config/amazon_s3.yml
* Add-ons:
 * SendGrid
* Custom Chef Recipes
 * Sidekiq
