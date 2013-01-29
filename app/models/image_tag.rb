# == Schema Information
#
# Table name: image_tags
#
#  id         :integer          not null, primary key
#  image_id   :integer          not null
#  tag_id     :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class ImageTag < ActiveRecord::Base
  belongs_to :image
  belongs_to :tag
end
