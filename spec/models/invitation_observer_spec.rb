require 'spec_helper'

describe InvitationObserver do
  around(:each) do |example|
    Invitation.observers.enable  :invitation_observer
    example.run
    Invitation.observers.disable :invitation_observer
  end

  describe "after_invite" do
    it "calls Invitation Mailer" do
      InvitationMailer.should_receive(:send_invitation)
      create(:invitation).invite!
    end
  end
end
