Paperclip.interpolates(:attachment_singular) do |attachment, style|
  attachment.name.to_s.downcase
end

Paperclip.interpolates(:image_id) do |attachment, style|
  attachment.instance.image_id
end

Paperclip.interpolates(:order_id) do |attachment, style|
  attachment.instance.order_id
end
