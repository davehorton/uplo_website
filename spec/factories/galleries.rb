FactoryGirl.define do

  factory :gallery do
    user
    name { Faker::Lorem.name }
  end

end
