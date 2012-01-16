require 'spec_helper'

describe Api::GalleriesController do

  describe "GET 'list_galleries'" do
    it "returns http success" do
      get '/api/list_galleries'
      response.should be_success
    end
  end

end
