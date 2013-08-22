require 'spec_helper'

describe AuthenticationsController do
  let(:user) { create(:user) }

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "destroy action should destroy model and redirect to index action" do
    user.authentications.create(:provider => "MyString", :uid => 1)
    sign_in(user)
    authentication = user.authentications.first
    delete :destroy, :id => authentication
    Authentication.exists?(authentication.id).should be_false
  end
end
