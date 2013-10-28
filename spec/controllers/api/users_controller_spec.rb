require 'spec_helper'

describe Api::UsersController do

  login_user

  let!(:user) { create(:user) }

  context "#search" do

    context "should return all users" do
      it "when query not present" do
        get :search
        response.body.should_not be_blank
      end
    end

    context "should return appropriate users" do
      it "when query present" do
        another_user = create(:user, :first_name => "test", :last_name => "user")
        get :search, query: "test"
        response.body.should_not be_blank
      end
    end
  end
end


