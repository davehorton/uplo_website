class ProfileImage < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :user

  # Paperclip
  has_attached_file :data,
   :styles => {:thumb => '180x180#', :extra => '96x96#', :large => '67x67#', :medium => '48x48#', :small => '24x24#' },
   :storage => :s3,
   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
   :path => "avatar/:id/:style.:extension",
   :default_url => "/assets/avatar-default-:style.jpg"

  #validates_attachment_presence :data
  validates_attachment_content_type :data, :content_type => [ 'image/jpeg','image/jpg','image/png',"image/gif"],
                                      :message => 'filetype must be one of [.jpeg, .jpg, .png, .gif]'

  # CALLBACK
  after_create :update_last_used, :set_as_default

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
      ProfileImage.update_all '"default"=false', "user_id = #{ self.user_id } and id <> #{ self.id }"
    end
  end
end
