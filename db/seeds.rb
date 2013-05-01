# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Rails.cache.clear # in case caching is enabled

puts "Creating seed data..."

puts 'Creating sizes'
size5x5 = Size.create(width: 5, height: 5)
size5x7 = Size.create(width: 5, height: 7)
size8x8 = Size.create(width: 8, height: 8)
size8x10 = Size.create(width: 8, height: 10)
size12x12 = Size.create(width: 12, height: 12)
size12x16 = Size.create(width: 12, height: 16)
size20x24 = Size.create(width: 20, height: 24)
size24x36 = Size.create(width: 24, height: 36)

puts 'Creating mouldings'
print = Moulding.create(name: 'Print Only (Gloss)')
canvas = Moulding.create(name: 'Canvas')
Moulding.create(name: 'Plexi')

puts 'Creating products for private galleries'
Product.create(size: size5x5, moulding: print, tier1_price: 10, tier2_price: 20, tier3_price: 30, tier4_price: 40, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50, private_gallery: true, public_gallery: false)
Product.create(size: size5x5, moulding: canvas, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50, private_gallery: true, public_gallery: false)
Product.create(size: size5x7, moulding: print, tier1_price: 10, tier2_price: 20, tier3_price: 30, tier4_price: 40, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50, private_gallery: true, public_gallery: false)
Product.create(size: size5x7, moulding: canvas, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50, private_gallery: true, public_gallery: false)

puts 'Creating products for public galleries'
Product.create(size: size8x8, moulding: print, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: size8x8, moulding: canvas, tier1_price: 50, tier2_price: 80, tier3_price: 90, tier4_price: 100, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: size8x10, moulding: print, tier1_price: 20, tier2_price: 30, tier3_price: 40, tier4_price: 50, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: size8x10, moulding: canvas, tier1_price: 50, tier2_price: 80, tier3_price: 90, tier4_price: 100, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: size24x36, moulding: print, tier1_price: 300, tier2_price: 600, tier3_price: 1000, tier4_price: 5000, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)
Product.create(size: size24x36, moulding: canvas, tier1_price: 500, tier2_price: 800, tier3_price: 1500, tier4_price: 7500, tier1_commission: 30, tier2_commission: 35, tier3_commission: 40, tier4_commission: 50)

puts "Admin login: admin/secret"
admin = User.new({
  :email => "admin@uplo.com",
  :paypal_email => "admin@uplo.com",
  :paypal_email_confirmation => "admin@uplo.com",
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
  email = Faker::Internet.email

  user = User.new({
    :email => email,
    :username => Faker::Internet.user_name,
    :paypal_email => email,
    :paypal_email_confirmation => email,
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

# 1 public gallery for a user
Gallery.create!(
  name: Faker::Lorem.word,
  user: user,
  description: Faker::Lorem.words
)

# 1 public gallery for admin user
Gallery.create!(
  name: Faker::Lorem.word,
  user: admin,
  description: Faker::Lorem.words
)

# 1 private gallery for admin user
Gallery.create!(
  name: Faker::Lorem.word,
  user: admin,
  description: Faker::Lorem.words,
  permission: :private
)

puts 'Creating gallery images...'

# 3 images for user's public gallery
gallery = user.galleries.first
3.times do |counter|
  img = gallery.images.create!(
    name: Faker::Lorem.words,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1,
    promoted: [true, false].sample
  )
end

# 2 images for admin's public gallery
gallery = admin.galleries.public_access.first
2.times do |counter|
  img = gallery.images.create!(
    name: Faker::Lorem.word,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1,
    promoted: [true, false].sample
  )
end

# 2 images for admin's private gallery
gallery = admin.galleries.private_access.first
2.times do |counter|
  img = gallery.images.create!(
    name: Faker::Lorem.word,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1
  )
end