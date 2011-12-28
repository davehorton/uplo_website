class Gallery < ActiveRecord::Base
  belongs_to :user
  has_many :images, :dependent => :destroy
  validates :user, :presence => true
  
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
  
  # INSTANCE METHODS
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
end
