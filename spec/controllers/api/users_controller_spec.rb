require 'spec_helper'

describe Api::UsersController do

  login_user

  let!(:user) { create(:user) }

  context "#search" do

    context "should return all users" do
      it "when query not present" do
        get :search
        response.body.should == ActiveModel::ArraySerializer.new(User.paginate_and_sort({}), root: "users", scope: subject.current_user, meta: { total: 2}).to_json

      end
    end

    context "should return appropriate users" do
      it "when query present" do
        another_user = create(:user, :first_name => "test", :last_name => "user")
        get :search, query: "test"
        response.body.should == ActiveModel::ArraySerializer.new(User.search_scope("test").paginate_and_sort({}), root: "users", meta: { total: 1}).to_json
      end
    end
  end

  context "#show" do

    it "should display user details" do
      get :show, id: user.id
      response.body.should == UserSerializer.new(user).to_json
    end
  end

  context "#followers" do

    it "should display follower list" do
      user_follow = create(:user_follow, :user_id => user.id, followed_by: subject.current_user.id)
      get :followers, id: user.id
      response.body.should == ActiveModel::ArraySerializer.new(user.followers.paginate_and_sort({}), root: "users", scope: subject.current_user).to_json

    end
  end

  context "#following" do

    it "should display followed users list" do
      user_following = create(:user_follow, followed_by: user.id, :user_id => subject.current_user.id)
      get :following, id: user.id
      response.body.should == ActiveModel::ArraySerializer.new(user.followed_users.paginate_and_sort({}), root: "users", scope: subject.current_user).to_json

    end
  end

  context "#update_profile" do

    context "when user hash is blank" do
      it "should show error message" do
        post :update_profile, {:user => { }}
        response.body.should == "{\"msg\":\"common.invalid_params\"}"
      end
    end

    context "when user hash is not blank" do
      it "should update information" do
        post :update_profile, {"user"=>{"id"=>"#{subject.current_user.id}","email"=>"john@test.org", "location"=>"usa"}}
        response.body.should == UserSerializer.new(subject.current_user, scope: subject.current_user).to_json
        subject.current_user.email.should == "john@test.org"
      end
    end
  end

  context "#set_follow" do

    context "when current user follows current user" do
      it "should show error message" do
        post :set_follow, {"user_id"=>"#{subject.current_user.id}", "follow"=>"1"}
        response.body.should == "{\"msg\":\"You cannot follow yourself\"}"
      end
    end

    context "when current user has already followed the user" do
      it "should show error message" do
        user_follow = create(:user_follow, followed_by: subject.current_user.id, user_id: user.id )
        post :set_follow, {"user_id"=>"#{user.id}", "follow"=>"1"}
        response.body.should == "{\"msg\":\"You are already following this user\"}"
      end
    end

    context "follow user" do
      it "should be successfull" do
        post :set_follow, {"user_id"=>"#{user.id}", "follow"=>"1"}
        response.should be_success
        response.body.should == UserFollow.last.to_json
        UserFollow.last.followed_by.should == subject.current_user.id
      end
    end

  end

  context "#withdraw" do

    context "without paypal email" do
      it "should show error message" do
        post :withdraw, {"amount"=>"88.0"}
        response.should_not be_success
        response.body.should == "{\"msg\":\"Paypal email must exist\"}"
      end
    end

  end

  context "#get_user_card_info" do

    it "should display the credit card details" do
      subject.current_user.update_attributes(name_on_card: "john doe", card_type: "Visa", card_number: "4111111111111111", expiration: "11/2022", cvv: "123")
      get :get_user_card_info
      response.body.should == "{\"card_info\":{\"name_on_card\":\"john doe\",\"card_type\":\"Visa\",\"card_number\":\"4111111111111111\",\"expiration\":\"\",\"cvv\":\"***\"}}"
    end
  end

  context "#logout" do

    it "should display message and sign out user" do
      post :logout
      response.body.should == "{\"msg\":\"signed_out\"}"
    end
  end

end

