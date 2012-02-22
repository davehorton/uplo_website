namespace :search do
  desc 'Rebuild Flying Sphinx index'
  #task :reindex => ["fs:rebuild"]
  
  task :reindex => :environment do    
    Rails.logger.info("==== Begin fs:rebuild ====")
    Rake::Task["fs:rebuild"].invoke
    Rails.logger.info("==== Finished fs:rebuild ====")
  end
end
