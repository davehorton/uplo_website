namespace :db do
  desc 'Drop, re-create and populate sample data'
  task :bootstrap => [:drop, :create, :migrate, :seed, :sample_data]
end
