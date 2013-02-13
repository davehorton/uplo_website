Paperclip.interpolates(:s3_path_url) { |attachment, style|
  "#{attachment.s3_protocol}://#{attachment.bucket_name}.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
}

Paperclip.registered_attachments_styles_path = File.join(Rails.root, "/config/paperclip_attachments.yml")
