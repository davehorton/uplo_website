class ImageFlag < ActiveRecord::Base
  FLAG_TYPE = {
    'terms_of_use_violation' => 1,
    'copyright' => 2,
    'nudity' => 3
  }

  belongs_to :image
  belongs_to :reporter, :class_name => 'User', :foreign_key => :reported_by

  validates_presence_of :image_id, :reported_by, :flag_type, :message => 'cannot be blank'
  validates :description, length: { maximum: 255, message: 'cannot exceed 255 characters' }, :unless => :nudity?
  validate  :description_presence, :unless => :nudity?

  def self.flag_type_string(number)
    result = ""
    number = number.to_i

    FLAG_TYPE.each do |name, num|
      if number == num
        result = I18n.t("admin.flagged_images_type.#{name}")
        break
      end
    end

    return result
  end

  def nudity?
    self.flag_type == FLAG_TYPE['nudity']
  end

  # custom validator so that we can display different messages
  def description_presence
    return if self[:description].present?

    self.flag_type = self[:flag_type].try(:to_i)

    case self.flag_type
    when FLAG_TYPE['terms_of_use_violation']
      errors.add(:description, I18n.t("image_flag.missing_description_terms_of_use_violation"))
    when FLAG_TYPE['copyright']
      errors.add(:description, I18n.t("image_flag.missing_description_copyright"))
    else
      errors.add(:description, "Unknown violation type!")
    end
  end

  def reported_date
    self.created_at.strftime('%b %d, %Y')
  end

  def flag_type_string
    self.class.flag_type_string(self.flag_type)
  end
end
