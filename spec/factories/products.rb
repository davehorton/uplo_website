# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    tier_id "MyString"
    size_id "MyString"
    moulding_id "MyString"
    price "9.99"
    commission "9.99"
  end
end
