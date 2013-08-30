config = YAML::load_file("#{Rails.root}/config/social.yml")[Rails.env]

FACEBOOK_CONFIG  = config['facebook']
TWITTER_CONFIG   = config['twitter']
FLICKR_CONFIG    = config['flickr']
TUMBLR_CONFIG    = config['tumblr']
#PINTEREST_CONFIG = config['pinterest']

# ENV['FACEBOOK_KEY'] = FACEBOOK_CONFIG["api_key"]
# ENV['FACEBOOK_SECRET'] = FACEBOOK_CONFIG["secret"]
# ENV["TWITTER_CONSUMER_KEY"] = TWITTER_CONFIG["consumer_key"]
# ENV["TWITTER_CONSUMER_SECRET"] = TWITTER_CONFIG["consumer_secret"]

# For Testing Purpose

ENV['FACEBOOK_KEY'] = '213194545511353'
ENV['FACEBOOK_SECRET'] = '81c15c35e5a29a7517360df8c1cd8fc3'
ENV['FACEBOOK_APP'] = 'Uplo_test'

# Production Facebook Settings

#ENV['FACEBOOK_KEY'] = '164091983778781'
#ENV['FACEBOOK_SECRET'] = '39feaa2763d6cf829991ebeff78f1439'
#ENV['FACEBOOK_APP'] = 'uploapp'

ENV["TWITTER_CONSUMER_KEY"] = '7jHkC1FBt3fvkpLD6Ul8g'
ENV["TWITTER_CONSUMER_SECRET"] = 'n9R54l0LzvZOAOMrs51VvEkxS9VUN5k5puJfCPD4pFw'

# ENV['FACEBOOK_KEY'] = '386167101484688'
# ENV['FACEBOOK_SECRET'] = '4da169450bec082f7b468769f0b36a7d'
# ENV['FACEBOOK_APP'] = 'uplotest'

# ENV["TWITTER_CONSUMER_KEY"] = '92pM5vB2rVy0aeB6FWyHA'
# ENV["TWITTER_CONSUMER_SECRET"] = 'ldKWe8Ge9Ahrfn7dQBjkrrg3ox5KBsXITi6Aw5Q'
