require 'spec_helper'

describe Notification do
  let(:image) { create(:image) }
  let(:liked_image) { create(:image_with_image_likes) }
  let(:image_one_like) { create(:image_with_one_like) }

  describe ".deliver_image_notification" do
  end

  describe ".check_others" do
    context "with images like greater than others count" do
      it "should return proper message" do
        Notification.check_others(liked_image.id).should == " and 2 others "
      end
    end

    context "with images like equal to one" do
      it "should return proper message" do
        img_likes = create_list(:image_like, 2, :image_id => image.id)
        Notification.check_others(image.id).should == " and 1 other "
      end
    end

    context "with images like less than one" do
      it "should return proper message" do
        Notification.check_others(image.id).should == ' '
      end
    end
  end

  describe "action" do
    context "when type is not like" do
      it "should return proper type" do
        Notification.action(image.id, 1).should == " commented on"
      end
    end

    context "when the image has one like" do
      it "should return proper value" do
        Notification.action(image_one_like.id, 0).should == " likes"
      end
    end

    context "when image likes are present" do
      it "should return proper type" do
        Notification.action(liked_image.id, 0).should == " like"
      end
    end

    context "when purchased" do
      it "should return proper type" do
        Notification.action(image.id, 2).should == " purchased"
      end
    end
  end

end
