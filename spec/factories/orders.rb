FactoryGirl.define do
  factory :order do
    transaction_date { DateTime.now }
    user
    shipping_address
    billing_address
  end
end
