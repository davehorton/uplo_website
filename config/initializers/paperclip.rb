Paperclip.interpolates(:attachment_singular) do |attachment, style|
  attachment.name.to_s.downcase
end
