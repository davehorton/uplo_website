# only use RedisToGo in stg/prod; use local version of Redis in dev/test
ENV["REDISTOGO_URL"] = 'redis://username:password@domain.com:port/' if Rails.env.production? || Rails.env.staging?