IronWorker.configure do |config|
  config.token = ENV['IRON_WORKER_TOKEN']
  config.project_id = ENV['IRON_WORKER_PROJECT_ID']
  config.database = Rails.configuration.database_configuration[Rails.env]
  config.global_attributes[:rails_root] = Rails.root
  config.global_attributes[:aws_s3] = AMAZON_S3
end