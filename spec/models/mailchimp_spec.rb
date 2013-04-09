require 'spec_helper'

describe Mailchimp do
  let(:user) { create(:user) }

  describe ".subscribe_user" do
    it "should subscribe corresponding user" do
      Mailchimp.subscribe_user(user.id).should be_true
    end
  end

end
