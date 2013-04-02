# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :size do
    height 50
    width 45
  end

  factory :size_with_products, :parent => :size do
    after(:create) do |size|
      create_list(:product, 2, :size => size)
    end
  end

end
