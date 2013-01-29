# == Schema Information
#
# Table name: image_likes
#
#  id         :integer          not null, primary key
#  image_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class ImageLike < ActiveRecord::Base
  belongs_to :image
  belongs_to :user
end
