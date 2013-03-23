# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Rails.cache.clear # in case caching is enabled

puts "Creating seed data..."

puts "Admin login: admin/secret"
admin = User.new({
  :email => "admin@uplo.com",
  :username => "admin",
  :last_name => "Admin",
  :first_name => "Super",
  :password => "secret",
  :password_confirmation => "secret",
  :confirmation_token => nil,
  :confirmed_at => Time.now.advance(:hours => -1), #bypass email confirmation
  :confirmation_sent_at => Time.now.advance(:days => - 1, :hours => -1), #bypass email confirmation,
  :admin => true
}, :as => :admin)

admin.skip_confirmation!
admin.save!

puts 'Creating 10 users...'
10.times do |counter|
  user = User.new({
    :email => Faker::Internet.email,
    :username => Faker::Internet.user_name,
    :last_name =>  Faker::Name.last_name,
    :first_name =>  Faker::Name.first_name,
    :password => "secret",
    :password_confirmation => "secret",
    :confirmation_token => nil,
    :confirmed_at => Time.now, #bypass email confirmation
    :confirmation_sent_at => Time.now #bypass email confirmation,
  }, :as => :admin)
  user.skip_confirmation!
  user.save!
end

user = User.where(admin: false).first
puts "First non-admin user login: #{user.username}/secret"

puts 'Creating galleries...'
galleries = []
10.times do |counter|
  galleries << Gallery.create!({
    :name => Faker::Name.name,
    :user => user,
    :description => Faker::Lorem.paragraph
  })
end

puts 'Creating gallery images...'
gallery = galleries.first
10.times do |counter|
  img = gallery.images.create!({
    name: Faker::Lorem.words,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg")
  })
end
