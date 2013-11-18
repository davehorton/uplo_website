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

  context "#logout" do

    it "should display message and sign out user" do
      post :logout
      response.body.should == "{\"msg\":\"signed_out\"}"
    end
  end

end

