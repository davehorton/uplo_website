FactoryGirl.define do

  factory :user, :aliases => [:followed_user, :follower, :reporter] do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.email }
    username   { Faker::Internet.user_name }
    password   "secret"
    password_confirmation "secret"
    confirmation_token nil
    confirmed_at { 1.day.ago }
    confirmation_sent_at { 2.days.ago }
    shipping_address
    billing_address

    before(:create) do |user|
      user.skip_confirmation!
    end
  end

  factory :user_with_gallery, :parent => :user do
    after(:create) do |user|
      create(:gallery, :user => user)
    end
  end

  factory :user_with_image_likes, :parent => :user do
    after(:create) do |user|
      create(:gallery, :user => user)
    end
  end
end
