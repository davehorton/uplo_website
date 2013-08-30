config = YAML::load_file("#{Rails.root}/config/social.yml")[Rails.env]

FACEBOOK_CONFIG  = config['facebook']
TWITTER_CONFIG   = config['twitter']
FLICKR_CONFIG    = config['flickr']
TUMBLR_CONFIG    = config['tumblr']

ENV['FACEBOOK_KEY'] = FACEBOOK_CONFIG["api_key"]
ENV['FACEBOOK_SECRET'] = FACEBOOK_CONFIG["secret"]
ENV['FACEBOOK_APP'] = FACEBOOK_CONFIG["name"]

ENV["TWITTER_CONSUMER_KEY"] = TWITTER_CONFIG["consumer_key"]
ENV["TWITTER_CONSUMER_SECRET"] = TWITTER_CONFIG["consumer_secret"]
