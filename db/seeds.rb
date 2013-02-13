# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

admin = User.new
admin.assign_attributes({
  :email => "admin@uplo.com",
  :username => "admin",
  :last_name => "Admin",
  :first_name => "Super",
  :password => "123456",
  :password_confirmation => "123456",
  :confirmation_token => nil,
  :confirmed_at => Time.now.advance(:hours => -1), #bypass email confirmation
  :confirmation_sent_at => Time.now.advance(:days => - 1, :hours => -1), #bypass email confirmation,
  :is_admin => true
}, :as => :admin)

admin.skip_confirmation!
admin.save!

# Users
user = User.new({
  :email => "user@uplo.com",
  :username => "user",
  :last_name => "User",
  :first_name => "Sample",
  :password => "123456",
  :password_confirmation => "123456",
  :confirmation_token => nil,
  :confirmed_at => Time.now.advance(:hours => -1), #bypass email confirmation
  :confirmation_sent_at => Time.now.advance(:days => - 1, :hours => -1) #bypass email confirmation
})
user.skip_confirmation!
user.save!

50.times do |counter|
  begin
    user = User.new({
      :email => Faker::Internet.email,
      :username => Faker::Internet.user_name,
      :last_name =>  Faker::Name.last_name,
      :first_name =>  Faker::Name.first_name,
      :password => "123456",
      :password_confirmation => "123456",
      :confirmation_token => nil,
      :confirmed_at => Time.now, #bypass email confirmation
      :confirmation_sent_at => Time.now #bypass email confirmation,
    })
    user.skip_confirmation!
    user.save!
  rescue Exception
  end
end

# Galleries
galleries = []
user = User.first
20.times do |counter|
  galleries << Gallery.create!({
    :name => Faker::Name.name,
    :user => user,
    :permission => "public",
    :description => Faker::Lorem.paragraph
  })
end

# Images
# Run: "rake db:seed with_sample_image=true" to run this step
if ENV["with_sample_image"]
  gallery = galleries.first
  40.times do |counter|
    img = gallery.images.create!({
      :name => Faker::Lorem.words,
      :data => File.open(Dir.glob(File.join(Rails.root, 'public/assets', 'gallery-thumb.jpg')).sample)
    })
  end
end
