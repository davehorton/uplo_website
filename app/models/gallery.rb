class Gallery < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :user
  has_many :images, :dependent => :destroy
  
  # VALIDATIONS
  validates :name, :presence => true
  validates :user, :presence => true
  
  # CALL BACK
  after_initialize :init_permission
  
  include ::SharedMethods::Paging
  
  # CLASS METHODS
  class << self
    def load_galleries(params = {})
      paging_info = parse_paging_options(params)
      self.includes(:images).paginate(
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
  
  # PROTECTED INSTANCE METHODS 
  protected
  
  def init_permission
    if self.new_record? && self.permission.blank?
      self.permission = "public"
    end    
  end
end
