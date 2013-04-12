# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :moulding do
    name "Moulding1"
  end

  factory :moulding_with_products, :parent => :moulding do
    after(:create) do |moulding|
      create_list(:product, 2, :moulding => moulding)
    end
  end

end
