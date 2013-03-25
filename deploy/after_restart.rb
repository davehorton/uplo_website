# ensures Sidekiq workers are using latest version of the app
sudo "monit -g uplo_web_sidekiq restart all"

# ensures memcached is not stale
run "cd #{current_path} && bundle exec rake cache:clear"