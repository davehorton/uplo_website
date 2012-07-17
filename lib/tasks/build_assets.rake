task :build_assets => "build_assets:run"
namespace :build_assets do
  desc "Package static assets"
  
  task :run => ["assets:clean", "assets:precompile"]
end
