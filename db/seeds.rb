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

user = User.create!({
  :email => "user@uplo.com",
  :username => "user",
  :last_name => "User",
  :first_name => "Sample",
  :password => "123456",
  :password_confirmation => "123456",
  :confirmation_token => nil,
  :confirmed_at => Time.now.advance(:hours => -1), #bypass email confirmation
  :confirmation_sent_at => Time.now.advance(:days => - 1, :hours => -1), #bypass email confirmation
})

user.galleries.create!({
  :user_id => user.id,
  :name => "The best of the year",
  :description => "There are a lot of artworks which are the best of the months and weeks in this year"
})

user.galleries.create!({
  :user_id => user.id,
  :name => "The best of the year",
  :description => "There are a lot of artworks which are the best of the months and weeks in this year"
})

user.galleries.create!({
  :user_id => user.id,
  :name => "The best of the year",
  :description => "There are a lot of artworks which are the best of the months and weeks in this year"
})



if admin.confirmed_at.blank?
  admin.confirmed_at = Time.now.advance(:hours => -1)
  admin.save
  user.confirmed_at = Time.now.advance(:hours => -1)
  user.save
end
