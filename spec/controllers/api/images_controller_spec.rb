require 'spec_helper'

describe Api::ImagesController do

  login_user

  let!(:square_size) { create(:size, width: 8, height: 8) }
  let!(:rectangular_size) { create(:size, width: 8, height: 10) }
  let!(:square_product) { create(:product, size: square_size) }
  let!(:rectangular_product) { create(:product, size: rectangular_size) }

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  context "#pricing" do

    context "should return result" do

      it "when image id is present" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ) )
        get :pricing, id: image.id
        response.body.should_not be_blank
        response.body.should == image.reload.pricing_tiers.to_json
      end

      it "when gallery id, width and height present" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ) )
        get :pricing, width: image.image.width, height: image.image.height, gallery_id: image.gallery_id
        response.body.should == image.reload.pricing_tiers.to_json
      end
    end


    context "should not return result" do

      it "when image id is not present" do
        get :pricing
        response.body.should == "{}"
      end

      it "when gallery id not present" do
        gallery = create(:gallery, user: subject.current_user )
        get :pricing, width: 1500, height: 1200
        response.body.should == "{}"
      end

      it "when height not present" do
        gallery = create(:gallery, user: subject.current_user )
        get :pricing, width: 1500, gallery_id: gallery.id
        response.body.should == "{}"
      end

      it "when width id not present" do
        gallery = create(:gallery, user: subject.current_user )
        get :pricing, width: 1500, gallery_id: gallery.id
        response.body.should == "{}"
      end
    end

  end

end
