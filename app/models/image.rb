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
    
    def exposed_methods
      [:image_url, :image_thumb_url]
    end
    
    def exposed_attributes
      [:id, :name, :description, :data_file_name, :gallery_id]
    end
    
    def exposed_associations
      []
    end
    
    def except_attributes
      attrs = []
      self.attribute_names.each do |n|
        if !exposed_attributes.include?(n.to_sym)
          attrs << n
        end
      end
      attrs
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
  
  # Override Rails as_json method
  def as_json(options={})
    if (!options.nil?)
      super({ :except => self.class.except_attributes,
              :methods => self.class.exposed_methods, 
              :include => self.class.exposed_associations}.merge(options))
    else
      super({ :except => self.class.except_attributes,
              :methods => self.class.exposed_methods, 
              :include => self.class.exposed_associations})
    end
  end
  
  def exposed_methods
    self.class.exposed_methods
  end
    
  def exposed_attributes
    self.class.except_attributes
  end
  
  def exposed_associations
    self.class.exposed_associations
  end
end
