require 'spec_helper'

describe GalleryInvitation do
  let(:user) { create(:user) }
  let(:gallery) { create(:gallery) }
  let(:gallery_invitation) { create(:gallery_invitation) }
  let(:valid_emails) { [Faker::Internet.email, Faker::Internet.email, Faker::Internet.email].join(",") }
  let(:message) { Faker::Lorem.paragraph }

  it { should validate_presence_of(:emails) }
  it { should allow_value("a@b.com").for(:emails) }
  it { should_not allow_value("foo").for(:emails) }

  it { should validate_presence_of(:gallery_id) }

  it { should belong_to(:gallery) }

  describe ".create_invitations" do

    context "without emails" do
      it "should return error message" do
        GalleryInvitation.create_invitations(gallery, "", Faker::Lorem.paragraph).should == "Please enter emails"
      end
    end

    context "without message" do
      it "should return error message" do
        GalleryInvitation.create_invitations(gallery, valid_emails, "").should == "Please provide a message"
      end
    end

    context "with invalid emails" do
      it "should not create invitations" do
        emails = ['aaa', 'bbb'].join(",")
        expect { GalleryInvitation.create_invitations(gallery, emails, message)}.to change(GalleryInvitation, :count).by(0)
      end
    end

    context "with valid emails" do
      it "should create invitations" do
        expect { GalleryInvitation.create_invitations(gallery, valid_emails, message)}.to change(GalleryInvitation, :count).by(3)
      end
    end

    context "with existing emails" do
      it "should not create invitations" do
        emails = valid_emails
        expect { GalleryInvitation.create_invitations(gallery, emails, message)}.to change(GalleryInvitation, :count).by(3)
        expect { GalleryInvitation.create_invitations(gallery, emails, message)}.to change(GalleryInvitation, :count).by(0)
      end
    end

  end

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
