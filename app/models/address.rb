class Address < ActiveRecord::Base
	validates_presence_of :first_name, :last_name, :address, :city, :state, :zip_code
	validates_numericality_of :zip_code, :only_integer => true
	validates_length_of :zip_code, :is => 5
end
