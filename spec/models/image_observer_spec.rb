require 'spec_helper'

describe ImageObserver do
  around(:each) do |example|
    Image.observers.enable  :image_observer
    example.run
    Image.observers.disable :image_observer
  end

  let(:image){ create(:real_image) }
  let(:square_size) { create(:size, width: 8, height: 8) }
  let(:rectangular_size) { create(:size, width: 8, height: 10) }
  let(:square_product) { create(:product, size: square_size) }
  let(:rectangular_product) { create(:product, size: rectangular_size) }

  before do
    square_size
    rectangular_size
    square_product
    rectangular_product
  end


  describe "after_create" do
    it "calls updates column" do
      observer = ImageObserver.instance
      observer.after_create(image)
      image.user.photo_processing.should be_true
    end
  end

  describe "after_save" do
    it "should create default profile image for user" do
      image.update_attribute(:owner_avatar, true)
      observer = ImageObserver.instance
      observer.after_save(image)
      image.user.profile_images.should_not be_blank
    end
  end

end
