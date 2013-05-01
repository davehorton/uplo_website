# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gallery_invitation do
    email { Faker::Internet.email }
    gallery
  end
end
