class Gallery < ActiveRecord::Base
  include ::SharedMethods::Paging
  
  PUBLIC_PERMISSION = "public"
  
  # ASSOCIATIONS
  belongs_to :user
  has_many :images, :dependent => :destroy
  
  # VALIDATIONS
  validates :name, :presence => true
  validates :user, :presence => true
  
  # CALL BACK
  after_initialize :init_permission
  
  # CLASS METHODS
  class << self
    def load_galleries(params = {})
      paging_info = parse_paging_options(params)
      self.includes(:images).paginate(
        :page => paging_info.page_id, 
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end
    
    def load_popular_galleries(params)
      paging_info = parse_paging_options(params)
      self.includes(:images).where(:permission => PUBLIC_PERMISSION).paginate(
        :page => paging_info.page_id, 
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end
    
    def exposed_methods
      [:cover_image]
    end
    
    def exposed_attributes
      [:id, :name, :description]
    end
    
    def exposed_associations
      [:images]
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
    
    def default_serializable_options
      { :except => self.except_attributes,
        :methods => self.exposed_methods, 
        :include => self.exposed_associations
      }
    end
    
    protected
    
    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "name ASC"
        }
      end
      paging_options(options, default_opts)
    end
  end
  
  # PUBLIC INSTANCE METHODS
  def updated_at_string
    self.updated_at.strftime(I18n.t("date.formats.short"))
  end
  
  def permission_string
    if !self.permission.blank?
      I18n.t("gallery.permission.#{self.permission}")
    else
      ""
    end
  end
  
  # Get the cover image for this album.
  def cover_image
    return self.images.first
    
    if self.images.loaded?
      # Find in memory.
      self.images.detect{|img| img.is_gallery_cover?}
    else
      # Find in DB.
      self.images.where(:is_gallery_cover => true).first
    end
  end
  
  # Override Rails as_json method
  def as_json(options={})
    if (!options.blank?)
      super(self.default_serializable_options.merge(options))
    else
      super(self.default_serializable_options)
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
  
  def except_attributes
    self.class.except_attributes
  end
  
  def default_serializable_options
    self.class.default_serializable_options
  end
  
  def is_public?
    (self.permission == PUBLIC_PERMISSION)
  end
  
  def can_access?(user)
    (self.is_owner?(user) || self.is_public?)   
  end
  
  def is_owner?(user)
    (user && self.user_id == user.id)
  end
  
  # PROTECTED INSTANCE METHODS 
  protected
  
  def init_permission
    if self.new_record? && self.permission.blank?
      self.permission = PUBLIC_PERMISSION
    end    
  end
end
