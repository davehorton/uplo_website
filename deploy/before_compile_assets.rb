%w(amazon_s3 social).each do |file_name|
  run "ln -nfs #{shared_path}/config/#{file_name}.yml #{release_path}/config/#{file_name}.yml"
end