FactoryGirl.define do
  factory :order do
    transaction_date { DateTime.now }
    user
    shipping_address
    billing_address
  end

  factory :order_with_line_items, :parent => :order do
    after(:create) do |order|
      create_list(:line_item, 2, :order => order)
    end
  end

end
