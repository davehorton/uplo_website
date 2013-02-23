port = ENV["PORT"].to_i
listen port, :tcp_nodelay => true, :tcp_nopush => false
worker_processes 3 # amount of unicorn workers to spin up
timeout 300