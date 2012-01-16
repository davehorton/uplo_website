class Image < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  
  # ASSOCIATIONS
  belongs_to :gallery
  has_many :image_tags, :dependent => :destroy
  has_many :tags, :through => :image_tags
  has_many :image_likes, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  # Paperclip
  has_attached_file :data, 
   :styles => {:thumb => "180x180>", :small_preview => "100x100" }, 
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "image/:id/:style.:extension"
  
  #validates_attachment_presence :data
  validates_attachment_content_type :data, :content_type => [ 'image/jpeg','image/jpg','image/png',"image/gif"],
                                      :message => 'filetype must be one of [.jpeg, .jpg, .png, .gif]'

  
  # CLASS METHODS
  class << self
    def load_images(params = {})
      paging_info = parse_paging_options(params)
      paginate(
        :page => paging_info.page_id, 
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end
    
    def load_popular_images(params)
      paging_info = parse_paging_options(params)
      # TODO: calculate the popularity of the images: base on how many times an image is "liked".
      self.includes(:gallery).joins([:gallery]).
            where("galleries.permission = ?", Gallery::PUBLIC_PERMISSION).
            paginate(
              :page => paging_info.page_id, 
              :per_page => paging_info.page_size,
              :order => paging_info.sort_string)
    end
    
    def exposed_methods
      [:image_url, :image_thumb_url]
    end
    
    def exposed_attributes
      [:id, :name, :description, :data_file_name, :gallery_id]
    end
    
    def exposed_associations
      []
    end
    
    protected
    
    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "images.updated_at DESC"
        }
      end
      paging_options(options, default_opts)
    end
  end
  
  # INSTANCE METHODS
  def author
    if self.gallery && self.gallery.user
      self.gallery.user
    end
  end
  
  def image_url
    data.url
  end
  
  def image_thumb_url
    data.url(:thumb)
  end
  
  # Shortcut to get image's URL                                    
  def url(options = nil)
    self.data.url(options)
  end
end
