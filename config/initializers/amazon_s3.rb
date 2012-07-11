AMAZON_S3 = YAML.load_file(File.join(Rails.root, "config", "amazon_s3.yml"))[Rails.env]

# Config Paperclip for path

Paperclip.interpolates(:s3_path_url) { |attachment, style|
  "#{attachment.s3_protocol}//#{attachment.bucket_name}.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
}
