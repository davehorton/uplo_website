# == Schema Information
#
# Table name: profile_images
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  default           :boolean          default(FALSE), not null
#  link_to_image     :integer          default(0)
#  last_used         :datetime         not null
#  data_file_name    :string(255)      not null
#  data_content_type :string(255)      not null
#  data_file_size    :integer          not null
#  data_updated_at   :datetime         not null
#  created_at        :datetime
#  updated_at        :datetime
#

class ProfileImage < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :user
  belongs_to :source, :foreign_key => :link_to_image, :class_name => 'Image'

  # Paperclip
  has_attached_file :data,
    styles: { thumb:  '180x180#',
              extra:  '96x96#',
              large:  '67x67#',
              medium: '48x48#',
              small:  '24x24#' },
    path: "avatar/:id/:style.:extension",
    default_url: "/assets/avatar-default-:style.jpg"

  validates_attachment :data, :presence => true,
    :size => { :in => 0..10.megabytes, :message => 'File size cannot exceed 10MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg'],
      :message => 'File type must be one of [.jpeg, .jpg]' }

  # CALLBACK
  after_create :update_last_used, :set_as_default
  after_destroy :reset_avatar

  # INSTANT METHOD
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
      ProfileImage.update_all '"default"=false', "user_id = #{ self.user_id } and id <> #{ self.id }"
    end
  end

  def is_current_avatar?
    return self.default
  end

  def url(style = :thumb)
    self.data.expiring_url(style)
  end

  private
    def reset_avatar
      self.user.rollback_avatar if self.is_current_avatar?
      self.source.update_attribute('is_owner_avatar', false) if self.source
    end
end
