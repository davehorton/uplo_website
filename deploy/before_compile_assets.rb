%w(amazon_s3 authorizenet dropbox paypal redis social).each do |file_name|
  run "ln -nfs #{config.shared_path}/config/#{file_name}.yml #{config.release_path}/config/#{file_name}.yml"
end
