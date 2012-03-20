require 'iron_worker'

class FilterWorker < IronWorker::Base
  attr_accessor :rails_root #from iron_worker config
  attr_accessor :image_url
  attr_accessor :image_name
  attr_accessor :image_info
  attr_accessor :effect

  merge "filter_effect.rb"

  def run
    # file_path = "#{Rails.application.root}/tmp/#{image.name}"
    p '-'*100
    p rails_root
    p "../app/models/filter_effect.rb"
    file_path = "#{rails_root}/tmp/#{image_name}"
    FilterEffect::Effect.send(effect, image_url, file_path)
    image.data = File.open(file_path)

    #update image info
    image.attributes = image_info
    image.save
  end
end