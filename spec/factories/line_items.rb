FactoryGirl.define do
  factory :line_item do
    quantity 4
    price 500
    image
    product
    order
  end
end
