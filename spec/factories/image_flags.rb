FactoryGirl.define do
  factory :image_flag do
    reporter
    flag_type 1
    description "hello"
    image
  end

end
