require 'spec_helper'

describe GalleryInvitation do
  let(:user) { create(:user) }
  let(:gallery_invitation) { create(:gallery_invitation) }

  it { should validate_presence_of(:email) }
  it { should allow_value("a@b.com").for(:email) }
  it { should_not allow_value("foo").for(:email) }

  it { should validate_presence_of(:gallery_id) }

  it { should belong_to(:gallery) }

  describe "before create callback" do
    it "should set secret token" do
      gallery_invitation1 = create(:gallery_invitation, :secret_token => nil)
      gallery_invitation1.secret_token.should_not be_nil
    end
  end

  describe "#accepted?" do
    context "with user id" do
      it "should return true" do
        gallery_invitation.update_attribute(:user_id, user.id)
        gallery_invitation.accepted?.should be_true
      end
    end

    context "without user id" do
      it "should return false" do
        gallery_invitation.accepted?.should be_false
      end
    end
  end
end
