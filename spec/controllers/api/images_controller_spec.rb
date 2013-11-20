require 'spec_helper'

describe Api::ImagesController do

  login_user

  let!(:square_size) { create(:size, width: 8, height: 8) }
  let!(:rectangular_size) { create(:size, width: 8, height: 10) }
  let!(:square_product) { create(:product, size: square_size) }
  let!(:rectangular_product) { create(:product, size: rectangular_size) }
  let!(:product_option) { create(:product_option, product: square_product, description: "Borderless") }
  let!(:another_product_option) { create(:product_option, product: rectangular_product, description: "Borderless") }

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  context "#index" do

    context "when gallery id present" do

      it "should return matched result" do
        gallery = create(:gallery_with_images)
        get :index, gallery_id: gallery.id
        images = gallery.images.unflagged.with_gallery.paginate_and_sort({})
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 2 }).to_json
      end

    end

    context "when user is current user" do
      it "should return matched result" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ))
        get :index, user_id: subject.current_user.id
        images = subject.current_user.images.unflagged.with_gallery.paginate_and_sort({})
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1 }).to_json
      end

    end

    context "when user is not current user" do
      it "should return matched result" do
        image = create(:real_image)
        user = image.user
        get :index, user_id: user.id
        images = user.images.public_access.paginate_and_sort({})
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1 }).to_json
      end

    end
  end

  context "#liked" do

    context "should return matched result" do

      it "when current user present" do
        image = create(:image_like, :user => subject.current_user)
        get :liked
        images = subject.current_user.source_liked_images.paginate_and_sort({})
        response.body.should_not be_blank
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1}).to_json
      end

    end
  end

  context "#popular" do

    context "should return matched result" do

      it "when excluded image not present" do
        image = create(:real_image, promoted: true)
        get :popular
        images = Image.public_access.not_hidden.spotlight.includes(:gallery, :user).paginate_and_sort({sort_field: "random()"})
        response.body.should_not be_blank
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1}).to_json
      end

    end
  end

  context "#search" do

    context "should return matched result" do

      it "when query present" do
        image = create(:real_image, :name => "photo")
        get :search, query: "Photo"
        images = Image.search_scope("Photo").public_or_owner(subject.current_user).paginate_and_sort({})
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1 }).to_json
      end

    end
  end

  context "#search_by_id" do

    context "when ids present" do

      it "should return matched result" do
        image = create(:real_image)
        another_image = create(:real_image)
        get :search_by_id, {"ids"=>"#{[image.id, another_image.id]}"}
        images = [another_image, image]
        response.body.should == ActiveModel::ArraySerializer.new(images, scope: subject.current_user, root: "images").to_json
      end

    end
  end

  context "#by_friends" do

    context "should return matched result" do

      it "when friends present" do
        another_user = create(:user)
        image = create(:real_image, gallery: create(:gallery, user: another_user ))
        user_following = create(:user_follow, followed_by: subject.current_user.id, :user_id => another_user.id)
        get :by_friends
        images = subject.current_user.friends_images.public_access.paginate_and_sort({})
        response.body.should == ActiveModel::ArraySerializer.new(images, root: "images", scope: subject.current_user, meta: { total: 1 }).to_json
      end

    end
  end

  context "#like" do

    context "should like image" do

      it "when gallery id present" do
        image = create(:real_image)
        post :like, id: image.id
        response.body.should == "{\"image_likes_count\":1}"
      end

    end
  end

  context "#unlike" do

    context "should like image" do

      it "when gallery id present" do
        image = create(:real_image)
        put :unlike, id: image.id
        response.body.should == "{\"image_likes_count\":0}"
      end

    end
  end

  context "#flag" do

    context "should like image" do

      it "when gallery id present" do
        image = create(:image)
        post :flag, id: image.id, type: 3
        response.body.should == "{\"success\":true}"
      end

    end
  end

  context "#show" do

    context "should image details" do

      it "when gallery id present" do
        image = create(:real_image)
        get :show, id: image.id
        response.body.should_not be_blank
        response.body.should == ImageSerializer.new(image, scope: subject.current_user).to_json
      end

    end
  end

  context "#create" do

    context "when image hash is correct" do

      it "should create the image successfully" do
        image = build(:real_image, description: "my little experiences", gallery: create(:gallery, user: subject.current_user ) )
        post :create, {"gallery_id"=>"#{image.gallery_id}", "image"=>image.attributes}
        response.should be_success
        response.body.should == ImageSerializer.new(Image.last, scope: subject.current_user).to_json
        Image.count.should == 1
        Image.last.description.should == "my little experiences"
        Image.last.image_file_name.should_not be_nil
      end
    end

    context "when image hash is incorrect" do

      it "should show error messages" do
        image = build(:real_image, gallery: create(:gallery))
        post :create, {"gallery_id"=>"#{image.gallery_id}", "image"=>image.attributes}
        response.should_not be_success
        response.body.should == "{\"msg\":\"Not found\"}"
      end
    end

  end

  context "#update" do

    context "when image hash is correct" do

      it "should update the image successfully" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ) )
        put :update, {"id"=>"#{image.id}", "image"=>{"description"=>"a thing of beauty", "keyword"=>"nature", "gallery_id"=>"#{image.gallery.id}", "tier_id"=>"4"}}
        response.should be_success
        response.body.should == ImageSerializer.new(image.reload, scope: subject.current_user).to_json
        image.description.should == "a thing of beauty"
        image.tier_id.should == 4
      end
    end

    context "when image hash is incorrect" do

      it "should show error messages" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ) )
        put :update, {"id"=>"#{image.id}", "image"=>{"description"=>"a thing of beauty", "keyword"=>"nature", "gallery_id" => ""}}
        response.should_not be_success
        response.body.should == "{\"msg\":\"Gallery can't be blank\"}"
      end
    end

  end

  context "#destroy" do

    it "should destroy gallery" do
      gallery = create(:gallery, :user => subject.current_user)
      image = create(:image, :gallery => gallery)
      delete :destroy, id: image.id
      response.body.should == "{\"msg\":\"image deleted\"}"
    end

  end

  context "#total_sales", :not_being_used do
  end

  context "#purchases" do

    context "should return result" do

      it "when image id is present" do
        image = create(:real_image, gallery: create(:gallery, user: subject.current_user ) )
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        sale = Sales.new(image)
        get :purchases, id: image.id
        response.body.should_not be_blank
        response.body.should == {
          total_sale: sale.total_image_sales,
          total_quantity: sale.sold_image_quantity,
          data: sale.image_purchased_info[:data]
        }.to_json
      end

    end
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
