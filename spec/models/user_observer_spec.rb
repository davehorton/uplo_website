require 'spec_helper'

describe UserObserver do
  around(:each) do |example|
    User.observers.enable  :user_observer
    example.run
    User.observers.disable :user_observer
  end

  describe "after_create" do
    it "removes all existing invites" do
      invitations = create_list(:invitation, 2)
      invitations.first.update_attribute(:email, "test@test.com")
      inv2 = invitations.last
      user = create(:user, :email => "test@test.com")
      observer = UserObserver.instance
      observer.after_create(user)
      Invitation.all.should == [inv2]
    end
  end

end
