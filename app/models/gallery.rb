class Gallery < ActiveRecord::Base
  include ::Shared::QueryMethods

  classy_enum_attr :permission, default: 'public'

  belongs_to :user
  has_many   :images, :dependent => :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user, presence: true

  default_scope order('name asc')
  scope :closed, where(permission: Permission::Private.new)
  scope :open,   where(permission: Permission::Public.new)
  scope :with_images, includes(:images)

  # TODO: replace with pg full text search implementation
  def self.do_search(params = {})
=begin
    params[:filtered_params][:sort_field] = 'name' unless params[:filtered_params].has_key?("sort_field")
    paging_info = parse_paging_options(params[:filtered_params], {:sort_mode => :extended})

    self.search(
      SharedMethods::Converter::SearchStringConverter.process_special_chars(params[:query]),
      :star => true,
      :retry_stale => true,
      :page => paging_info.page_id,
      :per_page => paging_info.page_size )
=end
  end

  def get_images_without(ids)
    ids = [] unless ids.instance_of? Array
    self.images.unflagged.where("images.id not in (#{ids.join(',')})").order('name')
  end

  def updated_at_string
    self.updated_at.strftime("%m/%d/%y")
  end

  # Get the cover image for this album.
  def cover_image
    img = Image.find_by_gallery_id self.id, :conditions => { :gallery_cover => true }
    if img.nil? && self.images.unflagged.count > 0
      result = self.images.unflagged.first :order => 'images.created_at ASC'
    else
      result = img
    end
    result
  end

  def total_images
    images.unflagged.length
  end

  def last_update
    updated_at.strftime('%B %Y')
  end

  private

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
