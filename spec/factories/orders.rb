FactoryGirl.define do
  factory :order do
    transaction_date { DateTime.now }
    user
    address
  end
end
