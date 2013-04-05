require 'spec_helper'

describe UserDevice do
  let(:user_device) { create(:user_device) }

  it { should belong_to(:user) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:device_token) }
  it { should validate_presence_of(:last_notified) }

  it "is valid with a unique device token" do
    create(:user_device)
    expect(subject).to validate_uniqueness_of(:device_token)
  end

  describe "#active?" do
    context "with notify_purchases" do
      it "should return true" do
        user_device.active?.should be_true
      end
    end

    context "with notify_comments" do
      it "should return true" do
        user_device.active?.should be_true
      end
    end

    context "with notify_likes" do
      it "should return true" do
        user_device.active?.should be_true
      end
    end

    context "withot notify likes notify comments notify purchases " do
      it "should return false" do
        user_device.update_attributes(:notify_likes => false, :notify_comments => false, :notify_purchases => false)
        user_device.active?.should be_false
      end
    end
  end

end
