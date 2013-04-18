# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Rails.cache.clear # in case caching is enabled

puts "Creating seed data..."

puts 'Creating sizes'
smallest = Size.create(width: 8, height: 8)
smallest_rectangle = Size.create(width: 8, height: 10)
Size.create(width: 12, height: 12)
Size.create(width: 12, height: 16)
Size.create(width: 20, height: 24)
largest = Size.create(width: 24, height: 36)

puts 'Creating mouldings'
print = Moulding.create(name: 'Print Only (Gloss)')
canvas = Moulding.create(name: 'Canvas')
Moulding.create(name: 'Plexi')

puts 'Creating products'
Product.create(size: smallest, moulding: print, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: smallest, moulding: canvas, tier1_price: 50, tier2_price: 80, tier3_price: 90, tier4_price: 100, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: smallest_rectangle, moulding: print, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: smallest_rectangle, moulding: canvas, tier1_price: 50, tier2_price: 80, tier3_price: 90, tier4_price: 100, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: largest, moulding: print, tier1_price: 300, tier2_price: 600, tier3_price: 1000, tier4_price: 5000, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: largest, moulding: canvas, tier1_price: 500, tier2_price: 800, tier3_price: 1500, tier4_price: 7500, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)

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
    :name => Faker::Lorem.words,
    :user => user,
    :description => Faker::Lorem.paragraph
  })
end

puts 'Creating gallery images...'
gallery = galleries.first
10.times do |counter|
  img = gallery.images.create!({
    name: Faker::Lorem.words,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1
  })
end
