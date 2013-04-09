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
    pending "could not find implementation of owner_avatar_changed?"
  end

end
