FactoryGirl.define do

  factory :gallery do
    user
    name { Faker::Name.name }
  end

  factory :gallery_with_images, :parent => :gallery do
    after(:create) do |gallery|
      create_list(:image, 2, :name => "demo_image", :gallery => gallery)
    end
  end

  factory :gallery_with_images_without_cover, :parent => :gallery do
    after(:create) do |gallery|
      create_list(:image, 2, :gallery_cover => false, :gallery => gallery)
    end
  end

end
