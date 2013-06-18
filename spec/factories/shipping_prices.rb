# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shipping_price do
    product
    quantity 1
    amount "9.99"
  end
end
