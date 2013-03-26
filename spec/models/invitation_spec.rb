require 'spec_helper'

describe Invitation do
  let(:invitation) { create(:invitation) }

  it { should validate_presence_of(:email) }
  it { should allow_value("a@b.com").for(:email) }
  it { should_not allow_value("foo").for(:email) }


  context "before validation" do
    it "strips whitespace from email" do
      invite = klass.new(email: 'someone@address.com    ')
      invite.valid?
      invite.email.should == 'someone@address.com'
    end
  end

  context "before create" do
    it "sets token" do
      invitation.token.should be
    end
  end

  it "has a default sort of created_at desc" do
    a = create(:invitation)
    b = create(:invitation)
    klass.all.should == [b, a]
  end

  describe ".requested" do
    it "finds items without an invited_at set" do
      invited = create(:invitation, invited_at: 1.day.ago)
      requested = create(:invitation)
      klass.requested.should == [requested]
    end
  end

  describe "invite!" do
    it "sets invited_at" do
      invitation.invite!
      invitation.should be_invited_at
    end
  end
end
