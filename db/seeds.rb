# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Rails.cache.clear # in case caching is enabled

puts "Creating seed data..."

puts 'Creating sizes'
size5x5   = Size.create(height: 5, width: 5)
size5x7   = Size.create(height: 5, width: 7)
size8x8   = Size.create(height: 8, width: 8)
size8x10  = Size.create(height: 8, width: 10)
size12x12 = Size.create(height: 12, width: 12)
size12x16 = Size.create(height: 12, width: 16)
size20x24 = Size.create(height: 20, width: 24)
size24x36 = Size.create(height: 24, width: 36)

puts 'Creating mouldings'
print = Moulding.create(name: 'Print Only (Gloss)')
luster = Moulding.create(name: 'Print Only (Luster)')
canvas = Moulding.create(name: 'Canvas')
plexi = Moulding.create(name: 'Plexi')

puts 'Creating products for private galleries'
p = Product.create(size: size5x5, moulding: print, tier1_price: 10, tier2_price: 20, tier4_price: 30, tier5_price: 40, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50, private_gallery: true, public_gallery: false)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size5x5, moulding: canvas, tier1_price: 20, tier2_price: 30, tier4_price: 40, tier5_price: 50, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50, private_gallery: true, public_gallery: false)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size5x7, moulding: print, tier1_price: 10, tier2_price: 20, tier4_price: 30, tier5_price: 40, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50, private_gallery: true, public_gallery: false)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size5x7, moulding: canvas, tier1_price: 20, tier2_price: 30, tier4_price: 40, tier5_price: 50, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50, private_gallery: true, public_gallery: false)
p.product_options.create(description: 'Borderless')




puts 'Creating products for public galleries'
p = Product.create(size: size8x8, moulding: print, tier1_price: 20, tier2_price: 30, tier4_price: 40, tier5_price: 50, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 30.0)

p = Product.create(size: size8x8, moulding: luster, tier1_price: 20, tier2_price: 30, tier4_price: 40, tier5_price: 50, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 20.0)

p = Product.create(size: size8x8, moulding: canvas, tier1_price: 50, tier2_price: 80, tier4_price: 90, tier5_price: 100, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size8x8, moulding: plexi, tier1_price: 20, tier2_price: 30, tier4_price: 40, tier5_price: 50, tier1_commission: 30, tier2_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')



p = Product.create(size: size8x10, moulding: print, tier1_price: 32, tier2_price: 60, tier3_price: 150, tier4_price: 240, tier5_price: 720, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 20.0)


p = Product.create(size: size8x10, moulding: luster, tier1_price: 32, tier2_price: 60, tier3_price: 150, tier4_price: 240, tier5_price: 720, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 20.0)

p = Product.create(size: size8x10, moulding: canvas, tier1_price: 50, tier2_price: 80, tier3_price: 150, tier4_price: 320, tier5_price: 960, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size8x10, moulding: plexi, tier1_price: 85, tier2_price: 200, tier3_price: 300, tier4_price: 400, tier5_price: 1200, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')



p = Product.create(size: size12x16, moulding: plexi, tier1_price: 175, tier2_price: 350, tier3_price: 550, tier4_price: 800, tier5_price: 2400, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 20.0)

p = Product.create(size: size12x16, moulding: canvas, tier1_price: 100, tier2_price: 200, tier3_price: 400, tier4_price: 800, tier5_price: 2400, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size12x16, moulding: print, tier1_price: 80, tier2_price: 200, tier3_price: 400, tier4_price: 800, tier5_price: 3000, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')




p = Product.create(size: size20x24, moulding: plexi, tier1_price: 250, tier2_price: 600, tier3_price: 1000, tier4_price: 1600, tier5_price: 4800, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 20.0)

p = Product.create(size: size20x24, moulding: canvas, tier1_price: 200, tier2_price: 400, tier3_price: 600, tier4_price: 1000, tier5_price: 4800, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size20x24, moulding: print, tier1_price: 175, tier2_price: 300, tier3_price: 800, tier4_price: 1200, tier5_price: 5000, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')






p = Product.create(size: size24x36, moulding: print, tier1_price: 200, tier2_price: 800, tier3_price: 1100, tier4_price: 1500, tier5_price: 6000, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')
p.product_options.create(description: '1/4 Border', border_top_bottom: 30.0)

p = Product.create(size: size24x36, moulding: canvas, tier1_price: 300, tier2_price: 600, tier3_price: 1000, tier4_price: 1450, tier5_price: 5500, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

p = Product.create(size: size24x36, moulding: plexi, tier1_price: 350, tier2_price: 1000, tier3_price: 1500, tier4_price: 2000, tier5_price: 5500, tier1_commission: 30, tier2_commission: 35, tier3_commission: 35, tier4_commission: 40, tier5_commission: 50)
p.product_options.create(description: 'Borderless')

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
  description: Faker::Lorem.sentence
)

# 1 public gallery for admin user
Gallery.create!(
  name: Faker::Lorem.word,
  user: admin,
  description: Faker::Lorem.sentence
)

# 1 private gallery for admin user
Gallery.create!(
  name: Faker::Lorem.word,
  user: admin,
  description: Faker::Lorem.sentence,
  permission: :private
)

gallery = user.galleries.first
puts "Creating 3 images for user's public gallery named #{gallery.name}..."

3.times do |counter|
  img = gallery.images.create!(
    gallery_id: gallery.id,
    name: Faker::Lorem.word,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1,
    promoted: [true, false].sample
  )
end

gallery = admin.galleries.public_access.first
puts "Creating 2 images for admin's public gallery named #{gallery.name}..."

2.times do |counter|
  img = gallery.images.create!(
    gallery_id: gallery.id,
    name: Faker::Lorem.word,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1,
    promoted: [true, false].sample
  )
end

gallery = admin.galleries.private_access.first
puts "Creating 2 images for admin's private gallery named #{gallery.name}..."

2.times do |counter|
  img = gallery.images.create!(
    gallery_id: gallery.id,
    name: Faker::Lorem.word,
    image: File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg"),
    tier_id: 1
  )
end

# ensure previously cached content is gone
Rails.cache.clear
