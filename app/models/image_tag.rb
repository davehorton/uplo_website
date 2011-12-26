class ImageTag < ActiveRecord::Base
  belongs_to :image
  belongs_to :tag
end
