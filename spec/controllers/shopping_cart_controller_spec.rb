require 'spec_helper'

describe ShoppingCartController do

  describe "GET 'add_to_cart'" do
    it "returns http success" do
      get 'add_to_cart'
      response.should be_success
    end
  end

end
