FactoryGirl.define do

  factory :size do
    width  8
    height 10
  end

  factory :rectangular_size, :parent => :size do
  end

  factory :square_size, :class => :size do
    width  8
    height 8
  end

  factory :size_with_products, :parent => :size do
    after(:create) do |size|
      create_list(:product, 2, :size => size)
    end
  end

end
