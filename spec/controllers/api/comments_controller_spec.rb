require 'spec_helper'

describe Api::CommentsController do

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

      it "when image id present" do
        image = create(:image_with_comments, gallery: create(:gallery, user: subject.current_user ) )
        get :index, image_id: image.id
        response.body.should == ActiveModel::ArraySerializer.new(image.comments.paginate_and_sort({}), root: "comments", scope: subject.current_user, meta: { total: 3 }).to_json
      end

    end
  end

  context "#create" do

    context "when comment hash is blank" do
      it "should show error message" do
        post :create, {:comment => { }}
        response.body.should == "{\"msg\":\"Not found\"}"
      end
    end

    context "when comment hash is not blank" do
      it "should create a new comment" do
        image = create(:image)
        post :create, {"comment"=>{"description"=>"a thing of beauty"}, "image_id"=>"#{image.id}"}
        response.body.should == CommentSerializer.new(Comment.last).to_json
        Comment.last.description.should == "a thing of beauty"
      end
    end
  end
end

