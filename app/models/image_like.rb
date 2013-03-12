class ImageLike < ActiveRecord::Base
  belongs_to :image, counter_cache: true
  belongs_to :user, counter_cache: true
end
