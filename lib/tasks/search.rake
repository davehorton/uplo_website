namespace :search do
  desc 'Rebuild Flying Sphinx index'

  task :reindex => :environment do
    if Rails.env.production?
      Rails.logger.info("==== Begin fs:rebuild ====")
      Rake::Task["fs:reindex"].invoke
      Rails.logger.info("==== Finished fs:rebuild ====")
    else
      Rake::Task["ts:reindex"].invoke
    end
  end
end
