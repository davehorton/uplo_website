class Address < ActiveRecord::Base
	validates_presence_of :first_name, :last_name, :street_address, :city, :state
  validates :zip, presence: true

  def in_new_york?
    state && (state.upcase == 'NY' || state.upcase == 'NEW YORK')
  end
end
