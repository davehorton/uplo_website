class Gallery < ActiveRecord::Base
  include ::Shared::QueryMethods

  classy_enum_attr :permission

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
      query = "#{query}%"
      galleries = galleries.where("galleries.name ILIKE (?) OR galleries.description ILIKE (?) OR galleries.keyword ILIKE (?)", query, query, query)
    end
    galleries
  end

  def get_images_without(ids, owner = nil)
    ids = [] unless ids.is_a?(Array)
    scoped = if owner
      self.images
    else
      self.images.unflagged
    end
    scoped.where("images.id not in (?)", ids).order('name')
  end

  def updated_at_string
    self.updated_at.strftime("%m/%d/%y")
  end

  def cover_image
    img = Image.unscoped.where(gallery_id: self.id, gallery_cover: true).first
    img = images.unflagged.first if img.nil?
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

  def accessible?(user = nil)
    return true if self.permission.public?
    user && (user.admin? || user.owns_gallery?(self) || self.gallery_invitations.exists?(user_id: user.id))
  end
end
