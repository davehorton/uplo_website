class Gallery < ActiveRecord::Base
  include ::Shared::QueryMethods

  classy_enum_attr :permission, default: 'public'

  belongs_to :user
  has_many   :images, :dependent => :destroy
  has_many :gallery_invitations, :dependent => :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user, presence: true

  default_scope order('galleries.name asc')
  scope :private_access, where(permission: Permission::Private.new.to_s)
  scope :public_access,  where(permission: Permission::Public.new.to_s)
  scope :with_images, includes(:images)

  #could not find implementation
  def self.search_scope(query)
    galleries = Gallery.scoped
    if query.present?
      query = query.gsub(/[[:punct:]]/, ' ').squish
      galleries = galleries.advanced_search_by_name_or_description_or_keyword(query, query, query)
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

  def cover_image
    img = Image.unscoped.where(gallery_id: self.id, gallery_cover: true).first
    img = images.unscoped.unflagged.first if img.nil?
    img
  end

  def total_images
    images.unflagged.count
  end

  def last_update
    updated_at.strftime('%B %Y')
  end

  def is_public?
    self.permission == "public"
  end

  def commission_percent?
    is_public? || has_commission
  end

end
