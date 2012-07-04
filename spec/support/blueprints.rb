require 'machinist/active_record'
require 'sham'
require 'faker'

# Make a user without confirmation.
User.blueprint do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name}
  email {Faker::Internet.email}
  username {Faker::Internet.user_name}
  password {"secret"}
  password_confirmation { "secret"}
  confirmation_token {""}
  confirmed_at {DateTime.now}
  confirmation_sent_at {DateTime.now}
  :skip_confirmation!
end

# Make a user that needs confirmation or you need manually call skip_confirmation! or confirm! method
User.blueprint(:need_confirmation) do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name}
  email {Faker::Internet.email}
  username {Faker::Internet.user_name}
  password {"secret"}
  password_confirmation { "secret"}
  confirmation_token {""}
  confirmed_at {DateTime.now}
  confirmation_sent_at {DateTime.now}
end

Gallery.blueprint do
  name {Faker::Name.name}
  user {User.make}
end

Image.blueprint do
  name {Faker::Name.name}
  gallery {Gallery.make}
end

Tag.blueprint do
  name {Faker::Name.name}
end

ImageTag.blueprint do
  image {Image.make}
  tag {Tag.make}
end

ImageLike.blueprint do
  image {Image.make}
  user {User.make}
end

Comment.blueprint do
  user {User.make}
  image {Image.make}
  description {Faker::Lorem.paragraph}
end

ImageFlag.blueprint do
  # Attributes here
end
