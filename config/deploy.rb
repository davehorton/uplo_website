after 'deploy:update_code' do
  run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
end
