class ProfileImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :source, :foreign_key => :link_to_image, :class_name => 'Image'

  has_attached_file :avatar,
    styles: { thumb:  '180x180#',
              extra:  '96x96#',
              large:  '67x67#',
              medium: '48x48#',
              small:  '24x24#' },
    default_url: "/assets/avatar-default-:style.jpg"

  validates_attachment :avatar, :presence => true,
    :size => { :in => 0..10.megabytes, :message => 'File size cannot exceed 10MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg'],
      :message => 'File type must be one of [.jpeg, .jpg]' }

  after_create :update_last_used, :set_as_default
  after_destroy :reset_avatar

  def update_last_used
    ProfileImage.transaction do
      self.last_used = Time.now
      if self.save
        self.user.hold_profile_images
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def set_as_default
    ProfileImage.transaction do
      self.update_attribute('default', true)
      self.update_attribute('last_used', Time.now)
      ProfileImage.update_all({ default: false }, "user_id = #{ self.user_id } and id <> #{ self.id }")
    end
  end

  def current_avatar?
    self.default
  end

  def url(style = :thumb)
    self.avatar.expiring_url(style)
  end

  private

    def reset_avatar
      user.rollback_avatar if current_avatar?
      source.update_attribute(:owner_avatar, false) if source
    end
end
