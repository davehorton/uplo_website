task :build_assets => "build_assets:run"
namespace :build_assets do
  desc "Package static assets"
  
  task :run => :environment do    
    asset_dir = File.join(Rails.root, "public/assets")
    puts "Cleaning up assets folder..."
    if !File.exist?(asset_dir)
      FileUtils.mkdir(asset_dir)
    else
      FileUtils.remove_dir(asset_dir)
      FileUtils.mkdir(asset_dir)
    end
    
    puts "Building static assets packages..."
    Rake::Task["assets:precompile"].invoke
  end
end
