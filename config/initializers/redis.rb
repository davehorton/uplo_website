REDIS_CONFIG = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env]

# Connect to Redis using the redis_config host and port
if REDIS_CONFIG
  $redis = Redis.new(host: REDIS_CONFIG['host'], port: REDIS_CONFIG['port'])
end