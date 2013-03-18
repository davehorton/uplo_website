FactoryGirl.define do

  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.email }
    username   { Faker::Internet.user_name }
    password   "secret"
    password_confirmation "secret"
    confirmation_token nil
    confirmed_at { 1.day.ago }
    confirmation_sent_at { 2.days.ago }

    before(:create) do |user|
      user.skip_confirmation!
    end
  end

end
