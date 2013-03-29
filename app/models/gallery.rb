class Gallery < ActiveRecord::Base
  include ::Shared::QueryMethods

  classy_enum_attr :permission, default: 'public'

  belongs_to :user
  has_many   :images, :dependent => :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user, presence: true

  default_scope order('galleries.name asc')
  scope :private_access, where(permission: Permission::Private.new.to_s)
  scope :public_access,  where(permission: Permission::Public.new.to_s)
  scope :with_images, includes(:images)

  before_create :set_permission

  #could not find implementation
  def self.search_scope(query)
    galleries = Gallery.scoped
    if query.present?
      query = query.gsub(/[[:punct:]]/, ' ').squish
      galleries = galleries.collect { |c| c.images.advanced_search_by_name_or_description_or_keyword(query, query, query) }
    end
    galleries
  end

  def get_images_without(ids)
    ids = [] unless ids.is_a?(Array)
    self.images.unflagged.where("images.id not in (?)", ids).order('name')
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

    def set_permission
      self.permission = Permission::Public.new.to_s
    end
end
