FactoryGirl.define do

  factory :image do
    gallery
    user { gallery.user } # intentional denormalization
    name { Faker::Lorem.name }
    image_file_name { 'test.jpg' }
    image_content_type { 'image/jpeg' }
    image_file_size { 128 }
  end

  factory :real_image, class: Image do
    gallery
    user { gallery.user }
    name { Faker::Lorem.name }
    image File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg")
  end

end
