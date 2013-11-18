require 'spec_helper'

describe RepliesController do
  let!(:user) { create(:user, email: "test@test.org") }
  let!(:square_size) { create(:size, width: 8, height: 8) }
  let!(:rectangular_size) { create(:size, width: 8, height: 10) }
  let!(:square_product) { create(:product, size: square_size) }
  let!(:rectangular_product) { create(:product, size: rectangular_size) }
  let!(:image) { create(:real_image) }

  it "should create a new comment for a specific image" do
    post :image_comment, {"to" => "reply+#{image.id}@reply.uplo.com", "from" => "test@test.org", "text" => "a reply to email"}
    Comment.count.should == 1
    Comment.last.image.should == image
    Comment.last.user.should == user
    Comment.last.description.should == "a reply to email"
  end
end

