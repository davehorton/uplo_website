class Gallery < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods::Converter

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
    def do_search(params = {})
      params[:filtered_params][:sort_field] = 'name' unless params[:filtered_params].has_key?("sort_field")
      paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

      self.search(
        SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query]),
        :star => true,
        :page => paging_info.page_id,
        :per_page => paging_info.page_size )
    end

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
      [:cover_image, :total_images]
    end

    def exposed_attributes
      [:id, :name, :description]
    end

    def exposed_associations
      [:images]
    end

    protected

    def parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "galleries.name ASC"
        }
      end
      paging_options(options, default_opts)
    end
  end

  # PUBLIC INSTANCE METHODS
  def get_images_without(ids)
    ids = [] unless ids.instance_of? Array
    self.images.where("id not in (#{ids.join(',')})").order('name')
  end

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

  def is_public?
    (self.permission == PUBLIC_PERMISSION)
  end

  def can_access?(user)
    (self.is_owner?(user) || self.is_public?)
  end

  def is_owner?(user)
    (user && self.user_id == user.id)
  end

  def total_images
    self.images.length
  end

  # PROTECTED INSTANCE METHODS
  protected

  def init_permission
    if self.new_record? && self.permission.blank?
      self.permission = PUBLIC_PERMISSION
    end
  end

  # indexing with thinking sphinx
  define_index do
    indexes name
    indexes description

    has user_id

    set_property :field_weights => {
      :name => 4,
      :description => 1,
    }

    if Rails.env.production?
      set_property :delta => FlyingSphinx::DelayedDelta
    else
      set_property :delta => true
    end
  end
end
