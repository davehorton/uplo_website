require 'spec_helper'

describe Api::GalleriesController do

  login_user

  let!(:square_size) { create(:size, width: 8, height: 8) }
  let!(:rectangular_size) { create(:size, width: 8, height: 10) }
  let!(:square_product) { create(:product, size: square_size) }
  let!(:rectangular_product) { create(:product, size: rectangular_size) }

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  context "#index" do

    context "should return matched result" do

      it "when user id present" do
        user = subject.current_user
        gallery = create(:gallery, user: user)
        get :index, user_id: user.id
        response.body.should == ActiveModel::ArraySerializer.new(user.public_galleries.scoped.paginate_and_sort({}), root: "galleries", meta: { total: 1 }).to_json
      end

      it "without user id" do
        user = subject.current_user
        gallery = create(:gallery, user: user)
        get :index
        response.body.should == ActiveModel::ArraySerializer.new(user.galleries.scoped.paginate_and_sort({}), root: "galleries", meta: { total: 1 }).to_json
      end

    end
  end

  context "#create" do

    context "when gallery hash is blank" do
      it "should show error message" do
        post :create, {:gallery => { }}
        response.body.should == "{\"msg\":\"Name can't be blank\"}"
      end
    end

    context "when comment hash is not blank" do
      it "should create a new comment" do
        post :create, {"gallery"=>{"description"=>"test description", "name"=>"First gallery", "permission"=>"public", "has_commission"=>"1", "keyword"=>"nature"}}
        response.body.should == GallerySerializer.new(Gallery.last).to_json
        Gallery.last.description.should == "test description"
        Gallery.last.name.should == "First gallery"
      end
    end
  end


  context "#update" do

    context "when gallery hash is correct" do

      it "should update the gallery successfully" do
        gallery = create(:gallery, user: subject.current_user )
        put :update, {"id"=>"#{gallery.id}", "gallery"=>{"description"=>"a thing of beauty", "keyword"=>"nature", "name" => "my new gallery"}}
        response.should be_success
        response.body.should == GallerySerializer.new(gallery.reload, scope: subject.current_user).to_json
        gallery.description.should == "a thing of beauty"
        gallery.name.should == "my new gallery"
      end
    end

    context "when gallery hash is incorrect" do

      it "should show error messages" do
        gallery = create(:gallery, user: subject.current_user )
        put :update, {"id"=>"#{gallery.id}", "gallery"=>{"description"=>"a thing of beauty", "keyword"=>"nature", "name" => ""}}
        response.should_not be_success
        response.body.should == "{\"msg\":\"Name can't be blank\"}"
      end
    end

  end

  context "#destroy" do

    it "should destroy gallery" do
      gallery = create(:gallery, :user => subject.current_user)
      delete :destroy, id: gallery.id
      response.body.should == "{\"msg\":\"gallery deleted\"}"
    end

  end
end

