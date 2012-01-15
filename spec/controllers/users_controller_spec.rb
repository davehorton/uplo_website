require 'spec_helper'

describe UsersController do

  before (:each) do
    @user = User.make!
    sign_in @user
  end

  describe "GET 'profile'" do
    
    it "should be successful" do
      get :profile
      response.should be_success
    end
        
  end

end
