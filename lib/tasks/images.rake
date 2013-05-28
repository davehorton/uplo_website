namespace :images do
  desc 'Generate preview images for print size options'
  task :generate_previews => :environment do
    Image.delay.generate_previews(since: 1.hour.ago)
  end
end