namespace :db do
  desc 'Drop, re-create and seed data'
  task :init => [:drop, :create, :migrate, :seed]
end
