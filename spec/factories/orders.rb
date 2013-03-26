FactoryGirl.define do
  factory :order do
    user
    shipping_address
    billing_address
  end
end
