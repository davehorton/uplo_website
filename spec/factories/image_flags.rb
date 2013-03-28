FactoryGirl.define do
  factory :image_flag do
    reported_by 1
    flag_type 1
    description "hello"
    image
  end
end
