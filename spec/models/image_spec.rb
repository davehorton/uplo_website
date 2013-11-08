require 'spec_helper'

describe Image do
  let(:image) { create(:image) }
  let(:square_size) { create(:size, width: 8, height: 8) }
  let(:rectangular_size) { create(:size, width: 8, height: 10) }
  let(:square_product) { create(:product, size: square_size) }
  let(:rectangular_product) { create(:product, size: rectangular_size) }
  let(:recent_order) { create(:order, :status => "shopping") }
  let(:finalized_order) { create(:order, :status => "completed") }

  before do
    square_size
    rectangular_size
    square_product
    rectangular_product
  end

  it { should belong_to(:active_user) }
  it { should belong_to(:user) }
  it { should belong_to(:gallery) }
  it { should belong_to(:public_gallery) }

  it { should have_many(:comments) }
  it { should have_many(:image_flags) }
  it { should have_many(:image_tags) }
  it { should have_many(:image_likes) }
  it { should have_many(:line_items) }
  it { should have_many(:orders) }
  it { should have_many(:tags) }

  it { should have_attached_file(:image) }
  it { should validate_presence_of(:gallery_id) }

  context "validating uploaded image" do
    subject { Image.new(gallery: create(:gallery)) }

    it { should validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/jpg') }
  end

  it "has a default sort of created_asc" do
    a = image
    b = create(:image)
    klass.all.should == [b, a]
  end

  it "has a removed scope" do
    image = create(:image, :removed => true)
    Image.removed.should == [image]
  end

  it "has a not_removed scope" do
    Image.not_removed.should == [image]
  end

  it "has a flagged scope" do
    new_image = create(:image_with_image_flags)
    Image.flagged.should == [new_image, new_image]
  end

  it "has a unflagged scope" do
    Image.unflagged.should == [image]
  end

  it "has a visible scope" do
    Image.visible.should == [image]
  end

  it "has a spotlight scope" do
    image.update_attribute(:promoted, true)
    Image.spotlight.should == [image]
  end

  it "has a not hidden scope" do
    image.update_attribute(:hidden_by_admin, false)
    Image.not_hidden.should == [image]
  end


  describe ".flagged_of_type" do
    context "when image flag type is nil" do
      it "should return flagged images" do
        new_image = create(:image_with_image_flags)
        Image.flagged_of_type(nil).should == [new_image, new_image]
      end
    end
    context "when image flag type is present" do
      it "should return flagged images of provided flag type" do
        new_image = create(:image_with_image_flags)
        new_image.image_flags.first.update_attribute(:flag_type, 2)
        Image.flagged_of_type(2).should == [new_image]
      end
    end
  end

  describe ".remove_all_flagged_images" do
    context "with flag type" do
      it "should update removed true for all flagged images" do
        img = create(:image)
        image_flag = create(:image_flag, :flag_type=> 2, :image_id => img.id)
        Image.remove_all_flagged_images(2)
        image.removed.should be_false
      end
    end
  end

  describe ".reinstate_all_flagged_images" do
    context "with flag type" do
      it "should update removed true for all flagged images" do
        image_flag = create(:image_flag, :flag_type=> 2, :image_id => image.id)
        Image.reinstate_all_flagged_images(2)
        image.image_flags.count.should be_zero
        image.removed.should be_false
      end
    end
  end

  describe "#flag" do
    context "when user equals flagged by user" do
      it "should return message" do
        image.flag!(image.user).should == {:success=>false, :msg=>"You cannot flag your own image."}
      end
    end

    context "when image has image_flags" do
      it "should return message" do
        user1 = create(:user)
        img = create(:image_with_image_flags)
        img.flag!(user1).should == {:success=>false, :msg=>"This image is already flagged."}
      end
    end

    context "when image not successfully flagged" do
      it "should return" do
        user1 = create(:user)
        image.flag!(user1).should == {:success=>false, :msg=>"Flag type cannot be blank, Description Unknown violation type!"}
      end
    end

    context "when image successfully flagged" do
      it "should return" do
        user1 = create(:user)
        image.flag!(user1, { :type => 1, :desc => "hello" }).should == {:success=>true}
        user1.banned.should be_false
      end
    end
  end

  describe ".search_scope" do
    context "when query name present" do
      it "should return searched results" do
        img1 = create(:image, :name => "test")
        Image.search_scope("Test").should == [img1]
      end
    end
    context "when query description present" do
      it "should return searched results" do
        img1 = create(:image, :description => "hello")
        Image.search_scope("h").should == [img1]
        Image.search_scope("abc").should == []
      end
    end
    context "when query keyword present" do
      it "should return searched results" do
        img1 = create(:image, :keyword => "public")
        Image.search_scope("Pub").should == [img1]
        Image.search_scope("pri").should == []
      end
    end

    context "should not return result" do
      it "when image is hidden by admin" do
        img1 = create(:image, :keyword => "public", :hidden_by_admin => true)
        Image.search_scope("Pub").should == []
      end

      it "when image belongs to a private gallery" do
        img1 = create(:image, :keyword => "public")
        img1.gallery.update_attribute(:permission, :private)
        Image.search_scope("Pub").should == []
      end
    end
  end

  describe ".public_or_owner" do
    context "when user condition matches" do
      it "returns matched images" do
        user = create(:user)
        new_image = create(:image, :user_id => user.id)
        Image.public_or_owner(user).should == [new_image]
      end
    end
    context "when gallery condition matches" do
      it "returns matched images" do
        another_user = create(:user)
        gallery = create(:gallery, :permission => "public")
        new_image = create(:image, :gallery_id => gallery.id)
        Image.public_or_owner(another_user).should == [new_image]
      end
    end
  end

  describe ".paginate_and_sort" do
    context "without sort_field" do
      it "should display output" do
        images = create_list(:image, 10)
        Image.paginate_and_sort({ :page => 1, :per_page => 5 }).should == images.reverse.first(5)
      end
    end

    context "with date uploaded as sort field" do
      it "should display output" do
        images = create_list(:image, 10)
        Image.paginate_and_sort({ :page => 1, :per_page => 5, :sort_field => "date_uploaded" }).should == images.reverse.first(5)
      end
    end

    context "with num of views as sort field" do
      it "should display output" do
        img1 = create(:image, :pageview => 3)
        img2 = create(:image, :pageview => 2)
        img3 = create(:image, :pageview => 1)
        Image.paginate_and_sort({ :page => 1, :per_page => 2, :sort_field => "num_of_views" }).should == [img1, img2]
      end
    end
  end

  describe ".popular_with_pagination" do
    context "with sort expression" do
      it "should display output", :flickering do
        images = create_list(:image, 10)
        Image.popular_with_pagination({ :page => 1, :per_page => 5}).should == images.reverse.first(5)
      end
    end
  end

  describe "gallery_cover=" do
    context "with is cover" do
      it "should update gallery cover" do
        gallery = create(:gallery_with_images)
        image.gallery_cover=(gallery.id)
        img1 =  gallery.images.first
        img1.gallery_cover.should be_false
      end
    end

    context "without is cover" do
      it "should be nil" do
        image.gallery_cover=().should be_nil
      end
    end
  end

  describe "owner_avatar=" do
    context "with is owner avatar" do
      it "should update owner avatar" do
        img = create(:image)
        image.owner_avatar=(img.user.id)
        img.user.images.first.owner_avatar.should be_false
      end
    end

    context "without is owner_avatar" do
      it "should be nil" do
        image.owner_avatar=().should be_nil
      end
    end
  end

  describe "#thumbnail_styles" do
    context "without generate_print_preview" do
      it "should return diffierent thubnail styles" do
        image.thumbnail_styles.should be_a(Hash)
      end
    end
  end

  describe "#liked_by?" do
    context "when liked by a user" do
      it "should return true" do
        another_user = create(:user, :first_name => "john")
        img_like = create(:image_like, :user_id => another_user.id, :image_id => image.id)
        image.liked_by?(another_user).should be_true
      end
    end
  end

  describe "#increase_pageview" do
    it "should increment counter" do
      image.update_attribute(:pageview, 3)
      image.increase_pageview
      image.reload
      image.pageview.should == 4
    end
  end

  describe "#sample_product_price" do
    context "when tier id matches" do
      it "should return price" do
        product = create(:product)
        img = create(:image, tier_id: 1)
        img.sample_product_price.to_i.should == 500
      end
    end

    context "when tier id does not match" do
      it "should return unknown" do
        Product.delete_all
        img = create(:image)
        img.sample_product_price.should == 0
      end
    end
  end

  describe "#square?" do
    context "when pure square" do
      subject { create(:image, square_aspect_ratio: true) }
      its(:square?) { should be_true }
    end

    context "when rectangular" do
      subject { create(:image, square_aspect_ratio: false) }
      its(:square?) { should be_false }
    end

    context "when slightly square" do
      before { subject.image.stub(:width => 1200, :height => 1300) }
      its(:square?) { should be_true }
    end

    context "when slightly square, longer width" do
      before { subject.image.stub(:width => 1300, :height => 1200) }
      its(:square?) { should be_true }
    end
  end

  describe "#available_products" do
    context "for a square image" do
      it "with public gallery should return appropriate products" do
        create(:image, square_aspect_ratio: true).available_products.should == [square_product]
      end

      it "without public gallery should return blank array" do
        square_product.update_attribute(:public_gallery, false)
        create(:image, square_aspect_ratio: true).available_products.should == []
      end
    end

    context "for a rectangular image" do
      it "with public gallery should return appropriate products" do
        create(:image, square_aspect_ratio: false).available_products.should == [rectangular_product]
      end

      it "without public gallery should return blank array" do
        rectangular_product.update_attribute(:public_gallery, false)
        create(:image, square_aspect_ratio: false).available_products.should == []
      end
    end

    context "for images belonging to private gallery" do
      it "with public gallery should return appropriate products" do
        create(:image, square_aspect_ratio: true)
        image.gallery.update_attribute(:permission, "private")
        square_product.update_attribute(:private_gallery, true)
        image.available_products.should == [square_product]
      end
    end

    context "for new images, when tmp_height, tmp_width and gallery_id is present" do
      it "with public gallery should return appropriate products" do
        image = create(:image, square_aspect_ratio: true)
        Image.new(tmp_width: image.image.width, tmp_height: image.image.height, gallery_id: image.gallery_id)
             .available_products.should == [square_product]
      end

      it "with public gallery should return appropriate products" do
        image = create(:image, square_aspect_ratio: false)
        Image.new(tmp_width: image.image.width, tmp_height: image.image.height, gallery_id: image.gallery_id)
             .available_products.should == [rectangular_product]
      end

    end
  end

  describe "#available_sizes" do
    it "should return uniq array" do
      image.available_sizes.should == [square_size]
    end
  end

  describe "#available_mouldings" do
    it "should return uniq array" do
      image.available_mouldings.should == [square_product.moulding]
    end
  end

  describe "#comments_number" do
    it "should return count" do
      img = create(:image_with_comments)
      img.comments_number.should == 3
    end
  end

  describe "#flagged?" do
    context "with image flags" do
      it "should return true", :flickering do
        img1 = create(:image_with_image_flags)
        img1.flagged?.should be_true
      end
    end
    context "without image flags" do
      it "should return false" do
        image.flagged?.should be_false
      end
    end
  end

  describe "#reinstate!" do
    context "with image flags" do
      it "should destroy image flags and remove" do
        img = create(:image_with_image_flags)
        img.reinstate!
        img.image_flags.count.should be_zero
        img.removed.should be_false
      end
    end
  end

  describe "#promote!" do
    it "should be true" do
      image.promote!
      image.promoted.should be_true
    end
  end

  describe "#demote!" do
    it "should be true" do
      image.demote!
      image.promoted.should be_false
    end
  end

  describe "#remove" do
   it "should be true" do
      image.remove!
      image.removed.should be_true
      #delay jobs test pending as gem not added
    end
  end

  describe "execute before create callback" do
    before { image.save }

    it "should set tier" do
      image.tier_id.should == 1
    end

    it "set name" do
      image.name.should == "test_image"
    end

    it "should set s3_expire_time" do
      "#{Time.zone.now.beginning_of_day.since 25.hours}"
    end

    it "should set user" do
      image.user_id.should == image.gallery.user_id
    end

    it "should set as cover if first one" do
      image.gallery_cover.should be_true
    end
  end

  describe "#owner?" do
    context "when user owns image" do
      let(:user) { image.user }

      it "should be true" do
        image.owner?(user).should be_true
      end
    end

    context "when user does not own image" do
      let(:user) { create(:user) }

      it "should be false" do
        image.owner?(user).should be_false
      end
    end

    context "when user is nil" do
      let(:user) { nil }

      it "should be false" do
        image.owner?(user).should be_false
      end
    end
  end

  describe "#destroy" do
    context "when purchased orders present" do
      it "should remove image and not destroy it" do
        line_item = create(:line_item, :image => image, :order => finalized_order)
        expect { image.destroy }.not_to change(Image, :count).by(-1)
        image.removed.should be_true
      end

      it "should remove line items only in cart" do
        line_item = create(:line_item, :image => image, :order => recent_order)
        expect { image.destroy }.to change(LineItem, :count).by(-1)
      end

      it "should not remove line items in placed orders" do
        finalized_line_item = create(:line_item, :image => image, :order => finalized_order)
        expect { image.destroy }.not_to change(LineItem, :count).by(-1)
      end
    end

    context "when purchased orders not present" do
      it "should destroy image" do
        line_item = create(:line_item, :image => image, :order => recent_order)
        expect { image.destroy }.to change(Image, :count).by(-1)
      end

      it "should destroy associated line items" do
        line_item = create(:line_item, :image => image, :order => recent_order)
        expect { image.destroy }.to change(LineItem, :count).by(-1)
      end
    end
  end

  describe ".custom_find" do
    let!(:image) { create(:image) }

    context "image not present" do
      it "should return nil" do
        Image.custom_find(89790).should be_nil
      end
    end

    context "image owner is blocked" do

      before do
        image.user.update_attribute(:banned, true)
      end

      it "should return nil if no logged in user present" do
        Image.custom_find(image.id).should be_nil
      end

    end

    context "image owner is NOT blocked" do
      it "should find image" do
        Image.custom_find(image.id).should == image
      end
    end
  end
end
