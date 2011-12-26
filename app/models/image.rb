class Image < ActiveRecord::Base
  belongs_to :gallery
  has_many :image_tags, :dependent => :destroy
  has_many :tags, :through => :image_tags
  has_many :image_likes, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  # Paperclip
  has_attached_file :data, 
   :styles => {:thumb => "180x180>" }, 
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "image/:id/:style.:extension"
  
  validates_attachment_presence :data
  validates_attachment_content_type :data, :content_type => [ 'image/jpeg','image/png' ],
                                      :message => 'file must be of filetype .jpg or .png'
end
