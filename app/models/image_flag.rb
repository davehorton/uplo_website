class ImageFlag < ActiveRecord::Base
  # CONSTANT
  FLAG_TYPE = {
    'nudity' => 1,
    'copyright' => 2,
    'terms_of_use_violation' => 3
  }

  # Associations
  belongs_to :image
  belongs_to :reporter, :class_name => 'User', :foreign_key => :reported_by

  # Validations
  validates_presence_of :image_id, :reported_by, :flag_type, :message => 'cannot be blank'

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

  # Instant methods
  def reported_date
    self.created_at.strftime('%b %d, %Y')
  end
end
