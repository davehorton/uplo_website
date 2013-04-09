require 'spec_helper'

describe CommentObserver do
  around(:each) do |example|
    Comment.observers.enable  :comment_observer
    example.run
    Comment.observers.disable :comment_observer
  end

  describe "after_create" do
    it "calls Notification deliver image notification" do
      Notification.should_receive(:deliver_image_notification)
      create(:comment)
    end
  end

end
