module SocialModule

  def get_auth_info
    @facebook_cfg = config_auth_file['facebook']
    @twitter_cfg = config_auth_file['twitter']
    @flickr_cfg = config_auth_file['flickr']
    @tumblr_cfg = config_auth_file['tumblr']
    @pinterest_cfg = config_auth_file['pinterest']
  end

  def config_auth_file
    config ||= YAML::load_file("#{Rails.root}/config/social_config.yml")[Rails.env]
  end

end