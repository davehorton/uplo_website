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

ENV['FACEBOOK_KEY'] = '164091983778781'
ENV['FACEBOOK_SECRET'] = '39feaa2763d6cf829991ebeff78f1439'
ENV["TWITTER_CONSUMER_KEY"] = '7jHkC1FBt3fvkpLD6Ul8g'
ENV["TWITTER_CONSUMER_SECRET"] = 'n9R54l0LzvZOAOMrs51VvEkxS9VUN5k5puJfCPD4pFw'
