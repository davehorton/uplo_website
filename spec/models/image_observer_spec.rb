require 'spec_helper'

describe ImageObserver do
  around(:each) do |example|
    Image.observers.enable  :image_observer
    example.run
    Image.observers.disable :image_observer
  end

  describe "after_create" do
    it "calls updates column" do
      image = create(:image)
      observer = ImageObserver.instance
      observer.after_create(image)
      image.user.photo_processing.should be_true
    end
  end

  describe "after_save" do
    it "should create default proifle image for user" do
      img = create(:image, :owner_avatar => false)
      observer = ImageObserver.instance
      observer.after_save(image)
      image.user.profile_images.should_not be_blank
    end
  end

end
