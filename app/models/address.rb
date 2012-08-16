class Address < ActiveRecord::Base
	validates_presence_of :first_name, :last_name, :address, :city, :state, :zip_code
end
