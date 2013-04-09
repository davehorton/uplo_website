require 'spec_helper'

describe ImageLikeObserver do
  around(:each) do |example|
    ImageLike.observers.enable  :image_like_observer
    example.run
    ImageLike.observers.disable :image_like_observer
  end

  describe "after_create" do
    it "calls Notification deliver image notification" do
      Notification.should_receive(:deliver_image_notification)
      create(:image_like)
    end
  end

end

