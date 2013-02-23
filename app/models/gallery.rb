# == Schema Information
#
# Table name: galleries
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  name        :string(255)      not null
#  description :text
#  delta       :boolean          default(TRUE), not null
#  created_at  :datetime
#  updated_at  :datetime
#  keyword     :string(255)
#  permission  :integer          default(1)
#

class Gallery < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods::Converter

  PUBLIC_PERMISSION = 1
  PRIVATE_PERMISSION = 0

  # ASSOCIATIONS
  belongs_to :user
  has_many :images, :dependent => :destroy

  # VALIDATIONS
  validates :name, :presence => true, :uniqueness => {:scope => :user_id, :case_sensitive => false}
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
        :retry_stale => true,
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
      [:cover_image, :total_images, :public_link, :last_update]
    end

    def exposed_attributes
      [:id, :name, :description, :permission, :keyword]
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
  def load_popular_images(params)
    paging_info = Image.parse_paging_options(params)
    self.images.un_flagged.paginate( :page => paging_info.page_id,
                          :per_page => paging_info.page_size,
                          :order => paging_info.sort_string )
  end

  def get_images_without(ids)
    ids = [] unless ids.instance_of? Array
    self.images.un_flagged.where("images.id not in (#{ids.join(',')})").order('name')
  end

  def updated_at_string
    self.updated_at.strftime("%m/%d/%y")
  end

  def permission_string
    if !self.permission.blank?
      I18n.t("gallery.permission")[self.permission.to_i]
    else
      ""
    end
  end

  def public_link
    url_for :controller => 'galleries', :action => 'public', :gallery_id => self.id,
            :only_path => false, :host => DOMAIN
  end

  # Get the cover image for this album.
  def cover_image
    img = Image.find_by_gallery_id self.id, :conditions => { :is_gallery_cover => true }
    if img.nil? && self.images.un_flagged.count > 0
      result = self.images.un_flagged.first :order => 'images.created_at ASC'
    else
      result = img
    end
    return result
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
    self.images.un_flagged.length
  end

  def last_update
      return self.updated_at.strftime('%B %Y')
  end

  # PROTECTED INSTANCE METHODS
  protected
    def init_permission
      if self.new_record? && self.permission.blank?
        self.permission = PUBLIC_PERMISSION
      end
    end

=begin
    define_index do
      # fields
      indexes name
      indexes description
      indexes keyword

      # attributes
      has user_id

      # weight
      set_property :field_weights => {
        :name => 7,
        :keyword => 3,
        :description => 1
      }

      if Rails.env.production?
        set_property :delta => FlyingSphinx::DelayedDelta
      else
        set_property :delta => true
      end
    end
=end
end
