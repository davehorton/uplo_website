# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  first_name       :string(255)
#  last_name        :string(255)
#  optional_address :string(255)
#  street_address   :string(255)
#  city             :string(255)
#  zip              :string(255)
#  state            :string(255)
#  phone            :string(255)
#  fax              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  country          :string(255)      default("usa")
#

class Address < ActiveRecord::Base
	validates_presence_of :first_name, :last_name, :street_address, :city, :state, :zip
	validates_numericality_of :zip, :only_integer => true
	validates_length_of :zip, :in => 1..6
end
