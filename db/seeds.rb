# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
=begin create_table "galleries", :force => true do |t|
  t.integer  "user_id",     :null => false
  t.string   "name",        :null => false
  t.text     "description"
  t.datetime "created_at"
  t.datetime "updated_at"
end
=end

admin = User.create!({
  :email => "admin@uplo.com",
  :username => "admin",
  :last_name => "Admin",
  :first_name => "Super",
  :password => "123456",
  :password_confirmation => "123456",
  :confirmation_token => nil,
  :confirmed_at => Time.now.advance(:hours => -1), #bypass email confirmation
  :confirmation_sent_at => Time.now.advance(:days => - 1, :hours => -1), #bypass email confirmation
})

if admin.confirmed_at.blank?
  admin.confirmed_at = Time.now.advance(:hours => -1)
  admin.save
end
