FactoryGirl.define do

  factory :comment do
    image
    user
    description { Faker::Lorem.name }
  end

end
