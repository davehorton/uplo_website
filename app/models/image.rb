class Image < ActiveRecord::Base
  include ::SharedMethods::Paging

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
  
  #validates_attachment_presence :data
  validates_attachment_content_type :data, :content_type => [ 'image/jpeg','image/png' ],
                                      :message => 'file must be of filetype .jpg or .png'

  
  # CLASS METHODS
  class << self
    def load_images(params = {})
      paging_info = parse_paging_options(params)
      paginate(
        :page => paging_info.page_id, 
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end
    
    protected
    
    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "updated_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end
  
  # INSTANCE METHODS
  
  # Shortcut to get image's URL                                    
  def url(options = nil)
    self.data.url(options)
  end
end
