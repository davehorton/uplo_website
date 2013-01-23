class ImageFlag < ActiveRecord::Base
  # CONSTANT
  FLAG_TYPE = {
    'terms_of_use_violation' => 1,
    'copyright' => 2,
    'nudity' => 3
  }

  # Associations
  belongs_to :image
  belongs_to :reporter, :class_name => 'User', :foreign_key => :reported_by

  # Validations
  validates_presence_of :image_id, :reported_by, :flag_type, :message => 'cannot be blank'
  validates :description, :length => {:maximum => 255, :message => 'cannot exceed 255 characters'}

  # CALL BACK
  after_save :set_image_delta_flag
  after_destroy :set_image_delta_flag

  # Class methods
  def self.process_description(flag_type, description)
    if flag_type.to_i == ImageFlag::FLAG_TYPE['nudity']
      result = ''
    elsif description.blank?
      result = nil
    else
      result = description
    end
    return result
  end

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

  # Instant methods
  def reported_date
    self.created_at.strftime('%b %d, %Y')
  end

  def flag_type_string
    self.class.flag_type_string(self.flag_type)
  end

  private
    def set_image_delta_flag
      if Rails.env.production?
        # Rake::Task['search:reindex'].reenable
        # Rake::Task['search:reindex'].invoke
        Rails.logger.info("==== Begin flying_sphinx: configure & index ====")
        FlyingSphinx::CLI.new('setup').run
        Rails.logger.info("==== Finished flying_sphinx: configure & index ====")
      else
        self.image.delta = true
        self.image.save
      end
    end
end
