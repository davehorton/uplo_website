Paperclip.interpolates(:attachment_singular) do |attachment, style|
  attachment.name.to_s.downcase
end

Paperclip.interpolates(:image_id) do |attachment, style|
  attachment.instance.image_id
end

Paperclip.interpolates(:order_id) do |attachment, style|
  attachment.instance.order_id
end

Paperclip.interpolates(:extension_or_default) do |attachment, style_name|
  ((style = attachment.styles[style_name.to_s.to_sym]) && style[:format]) ||
    (File.extname(attachment.original_filename).gsub(/^\.+/, "").presence || '.jpg')
end
