FactoryGirl.define do

  factory :image, :aliases => [:source] do
    gallery
    user { gallery.user } # intentional denormalization
    name { Faker::Name.name }
    image_file_name { 'test.jpg' }
    image_content_type { 'image/jpeg' }
    image_file_size { 128 }

    ignore do
      square_aspect_ratio true
    end

    before(:create) do |img, evaluator|
      if evaluator.square_aspect_ratio
        geo = Paperclip::Geometry.new(1200, 1200)
      else
        geo = Paperclip::Geometry.new(1200, 1500)
      end

      Paperclip::Geometry.stub(:from_file => geo)
    end

    after(:create) do |img, evaluator|
      # stub out image_meta data, see https://github.com/y8/paperclip-meta
      if evaluator.square_aspect_ratio
        img.image.stub(:width => 1200, :height => 1200, :size => 10000)
      else
        img.image.stub(:width => 1200, :height => 1500, :size => 10000)
      end
    end
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

  factory :image_with_image_likes, :parent => :image do
    after(:create) do |image|
      create_list(:image_like, 3, :image => image)
    end
  end

end
