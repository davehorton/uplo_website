require 'spec_helper'

describe Notification do
  let(:by_user) { create(:user, :first_name => "john", :last_name => "doe") }
  let(:image) { create(:image) }

  describe "action" do
    context "when type is a like" do
      it "should return proper message when admin" do
        by_user.update_attribute(:admin, true)
        Notification.action(0, by_user).should == "UPLO likes your image"
      end

      it "should return proper message when non admin" do
        Notification.action(0, by_user).should == "john doe likes your image"
      end
    end

    context "when type is a comment" do
      it "should return proper message when admin" do
        by_user.update_attribute(:admin, true)
        Notification.action(1, by_user).should == "UPLO left you a comment!"
      end

      it "should return proper message when non admin" do
        Notification.action(1, by_user).should == "john doe left you a comment!"
      end
    end

    context "when purchased" do
      it "should return proper type" do
        Notification.action(2, by_user).should == "You just made a sale!"
      end
    end
  end

end
