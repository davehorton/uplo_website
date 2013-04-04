FactoryGirl.define do

  factory :image, :aliases => [:source] do
    gallery
    user { gallery.user } # intentional denormalization
    name { Faker::Name.name }
    image_file_name { 'test.jpg' }
    image_content_type { 'image/jpeg' }
    image_file_size { 128 }
  end

  factory :real_image, :class => :image do
    gallery
    user { gallery.user }
    name { Faker::Name.name }
    image File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg")
  end

  factory :image_with_image_flags, :parent => :image do
    after(:create) do |image|
      create_list(:image_flag, 2, :image => image)
    end
  end

  factory :image_with_five_image_flags, :parent => :image do
    after(:create) do |image|
      create_list(:image_flag, 5, :image => image)
    end
  end

  factory :image_with_comments, :parent => :image do
    after(:create) do |image|
      create_list(:comment, 3, :image => image)
    end
  end

end
