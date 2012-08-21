class Address < ActiveRecord::Base
	validates_presence_of :first_name, :last_name, :street_address, :city, :state, :zip
	validates_numericality_of :zip, :only_integer => true
	validates_length_of :zip, :is => 5
end
