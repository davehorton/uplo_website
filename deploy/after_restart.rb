# ensures memcached is not stale
run "cd #{current_path} && bundle exec rake cache:clear"