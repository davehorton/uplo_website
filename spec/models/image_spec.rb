require 'spec_helper'

describe Image do
  let(:image){ create(:image) }
  let(:square_size) { create(:size, width: 8, height: 8) }
  let(:rectangular_size) { create(:size, width: 8, height: 10) }
  let(:square_product) { create(:product, size: square_size) }
  let(:rectangular_product) { create(:product, size: rectangular_size) }

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
  it { should validate_attachment_presence(:image) }
  it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/jpg') }

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
        Image.search_scope("---\n- test\n").should == [img1]
      end
    end
    context "when query description present" do
      it "should return searched results" do
        img1 = create(:image, :description => "hello")
        Image.search_scope("---\n- hello;").should == [img1]
        Image.search_scope("---\n- abc..;").should == []
      end
    end
    context "when query keyword present" do
      it "should return searched results" do
        img1 = create(:image, :keyword => "public")
        Image.search_scope("---\n- ...public;").should == [img1]
        Image.search_scope("---\n- private..;").should == []
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

  describe "#raw_purchased_info" do
    it "should paginate" do
      new_order = create(:order, :transaction_status => "completed", :transaction_date => "03-04-2012")
      line_items = create_list(:line_item, 20, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
      image.raw_purchased_info({ :page => 1, :per_page => 10 }).should == line_items.first(10)
    end
  end

  describe "#get_purchased_info" do
    pending "seems broken for sort_expression"
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
      it "should display output" do
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

  describe "get_price" do
    pending "method seems broken if no product found"
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
        img = create(:image, :tier_id => 1)
        img.sample_product_price.to_i.should == 500
      end
    end
    context "when tier id does not match" do
      it "should return unknown" do
        img = create(:image)
        img.sample_product_price.should == "Unknown"
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
    before do
      square_size
      rectangular_size
      square_product
      rectangular_product
    end

    context "for a square image" do
      it "should return appropriate products" do
        create(:image, square_aspect_ratio: true).available_products.should == [square_product]
      end
    end

    context "for a rectangular image" do
      it "should return appropriate products" do
        create(:image, square_aspect_ratio: false).available_products.should == [rectangular_product]
      end
    end
  end

  describe "#available_sizes" do
    before do
      square_size
      square_product
    end

    it "should return uniq array" do
      image.available_sizes.should == [square_size]
    end
  end

  describe "#available_mouldings" do
    before do
      square_size
      square_product
    end

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
      it "should return true" do
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

  describe "#total_sales" do
    context "without month" do
      it "should calculate total" do
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 35.0)
        image.total_sales.should == 200000.0
      end
    end
    context "with month" do
      it "should calculate total" do
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 500, :commission_percent => 35.0)
        image.total_sales("April")
        image.total_sales.should == 200000.0
      end
    end
  end

  describe "#sales_count" do
    context "without sales count key" do
      it "should calculate result" do
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.sales_count.should == 4
      end
    end

    context "with sales count key" do
      it "should display result" do
        image.sales_count.should be_zero
      end
    end
  end

  describe "get_monthly_sales_over_year" do
    context "without options" do
      it "should calculate result" do
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.get_monthly_sales_over_year("01-04-2013").should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=> 200000.0}]
      end
    end
    context "with options having report by quantity" do
      it "should calculate result" do
        new_order = create(:order, :transaction_status => "completed", :transaction_date => "05-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.get_monthly_sales_over_year("01-04-2013", { :report_by => "quantity"}).should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=> 4}]
      end
    end
    context "with options having report by price" do
      it "should calculate result" do
        new_order = create(:order, :transaction_status => "completed", :transaction_date => "05-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.get_monthly_sales_over_year("01-04-2013", { :report_by => "price"}).should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=>200000.0}]
      end
    end
  end

  describe "#sold_quantity" do
    context "without month" do
      it "should calculate total quantity" do
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.sold_quantity.should == 4
      end
    end
    context "with month" do
      it "should calculate total" do
        new_order = create(:order, :transaction_status => "completed", :transaction_date => "05-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        image.total_sales("April")
        image.sold_quantity.should == 4
      end
    end
  end

  describe "execute before create callback" do
    before { image.save }

    it "should set tier" do
      image.tier_id.should == 1
    end

    it "set name" do
      image.name.should == "test"
    end

    it "should set user" do
      image.user_id.should == image.gallery.user_id
    end

    it "should set as cover if first one" do
      image.gallery_cover.should be_true
    end
  end

end

