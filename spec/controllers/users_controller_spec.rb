require 'spec_helper'

describe UsersController do

  before (:each) do
    init_user_and_sign_in
  end

  describe "GET 'profile'" do
    
    it "should be successful" do
      get :profile
      response.should be_success
    end
        
  end

end
