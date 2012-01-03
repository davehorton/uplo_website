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
      paginate(
        :page => paging_info.page_id, 
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
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
    if self.images.loaded?
      # Find in memory.
      self.images.detect{|img| img.is_gallery_cover?}
    else
      # Find in DB.
      self.images.where(:is_gallery_cover => true).first
    end
  end
  
  # PROTECTED INSTANCE METHODS 
  protected
  
  def init_permission
    if self.new_record? && self.permission.blank?
      self.permission = "public"
    end    
  end
end
