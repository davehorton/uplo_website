FactoryGirl.define do
  factory :profile_image do
    user
    source
    avatar_updated_at {  Time.now }
    avatar_file_name { 'test.jpg' }
    avatar_content_type { 'image/jpeg' }
    avatar_file_size { 128 }
  end

  factory :real_profile_image, :class => :profile_image do
    user
    source
    avatar File.open("#{Rails.root}/spec/fixtures/assets/photo.jpg")
  end

end

