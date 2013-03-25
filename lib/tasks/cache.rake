namespace :cache do
  desc 'Clear the memory cache'
  task :clear => :environment do
    Rails.cache.clear if Rails.cache.respond_to?(:clear)
  end
end