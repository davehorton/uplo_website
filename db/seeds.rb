# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
admin = User.create!({
  :email => "admin@uplo.com",
  :username => "admin",
  :last_name => "Admin",
  :first_name => "Super",
  :password => "123456",
  :password_confirmation => "123456",
  :confirmation_token => nil,
  :confirmed_at => Time.now, #bypass email confirmation
  :confirmation_sent_at => Time.now, #bypass email confirmation
})

if admin.confirmed_at.blank?
  admin.confirmed_at = Time.now
  admin.save
end
