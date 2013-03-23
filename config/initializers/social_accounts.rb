config = YAML::load_file("#{Rails.root}/config/social.yml")[Rails.env]

FACEBOOK_CONFIG  = config['facebook']
TWITTER_CONFIG   = config['twitter']
FLICKR_CONFIG    = config['flickr']
TUMBLR_CONFIG    = config['tumblr']
#PINTEREST_CONFIG = config['pinterest']
