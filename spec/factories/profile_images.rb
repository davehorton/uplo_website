FactoryGirl.define do
  factory :profile_image do
    user
    source
    avatar_updated_at {  Time.now }
    avatar_file_name { 'test.jpg' }
    avatar_content_type { 'image/jpeg' }
    avatar_file_size { 128 }
  end
end

