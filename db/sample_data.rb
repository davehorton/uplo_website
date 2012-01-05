# Users
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

if user.confirmed_at.blank?
  user.confirmed_at = Time.now.advance(:hours => -1)
  user.save
end

5.times do |counter|
  user = User.create!({
    :email => Faker::Internet.email,
    :username => Faker::Internet.user_name,
    :last_name =>  Faker::Name.last_name,
    :first_name =>  Faker::Name.first_name,
    :password => "123456",
    :password_confirmation => "123456",
    :confirmation_token => nil,
    :confirmed_at => Time.now, #bypass email confirmation
    :confirmation_sent_at => Time.now, #bypass email confirmation
  })
  
  if user.confirmed_at.blank?
    user.confirmed_at = Time.now
    user.save
  end
end

# Galleries
galleries = []
user = User.first
20.times do |counter|
  galleries << Gallery.create!({
    :name => Faker::Company.name,
    :user => user,
    :permission => "public",
    :description => Faker::Lorem.words(3).map{|x| x.capitalize}.join(" ")
  })
end

# Images
gallery = galleries.first
40.times do |counter|
  img = gallery.images.create!({
    :name => Faker::Lorem.words,
    :photo => File.open(Dir.glob(File.join(Rails.root, 'public/assets', 'gallery-thumb.jpg')).sample)
  })
end
