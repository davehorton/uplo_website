class Address < ActiveRecord::Base
  validates_presence_of :first_name, :last_name, :street_address, :city, :state
  validates :zip, presence: true

  def in_new_york?
    state && (state.upcase == 'NY' || state.upcase == 'NEW YORK')
  end

  def cc_address_attributes
    {
      address: [street_address, optional_address].select(&:present?).join(', '),
      city: city,
      state: state,
      zip: zip
    }
  end
end
