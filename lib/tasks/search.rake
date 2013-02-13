require 'thinking_sphinx/tasks'
require 'flying_sphinx/tasks' if Rails.env.production?

namespace :search do
  desc 'Rebuild Flying Sphinx index'

  task :reindex do
    if Rails.env.production?
      Rails.logger.info("==== Begin flying_sphinx: configure & index ====")
      FlyingSphinx::CLI.new('setup').run
      Rails.logger.info("==== Finished flying_sphinx: configure & index ====")
    else
      Rails.logger.info("==== Begin thinking_sphinx:index ====")
      Rake::Task["thinking_sphinx:index"].reenable
      Rake::Task["thinking_sphinx:index"].invoke
      Rails.logger.info("==== Finished thinking_sphinx:index ====")
    end
  end
end
