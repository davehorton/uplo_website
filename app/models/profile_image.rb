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
    :size => { :in => 0..100.megabytes, :message => 'File size cannot exceed 100MB' },
    :content_type => { :content_type => [ 'image/jpeg','image/jpg'],
      :message => 'File must have an extension of .jpeg or .jpg' }

  after_create  :set_as_default

  def set_as_default
    transaction do
      user.profile_images.update_all(default: false)
      self.default = true
      save!
    end
  end

  def current_avatar?
    default
  end

  def s3_expire_time
    Time.zone.now.beginning_of_day.since 25.hours
  end

  def url(options = nil)
    storage = Rails.application.config.paperclip_defaults[:storage]
    case storage
      when :s3 then self.avatar.expiring_url(s3_expire_time, options)
      when :filesystem then avatar.url(options)
    end
  end
end

