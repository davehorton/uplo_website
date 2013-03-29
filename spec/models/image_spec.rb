require 'spec_helper'

describe Image do
  let(:image){ create(:image) }

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
    context "when flag type is nil" do
      it "should update removed true for all flagged images" do
        image_flag = create(:image_flag, :flag_type=> 2, :image_id => image.id)
        Image.remove_all_flagged_images(2)
        puts image.removed
      end
    end
  end

  describe ".search_scope" do
    context "when query name present" do
      it "should return searched results" do
        img1 = create(:image, :name => "demo_image")
        img2 = create(:image, :name => "test_image")
        Image.search_scope("---\n- demo\n- image\n").should == [img1]
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

  describe ".paginate_and_sort" do
    pending "add examples"
  end

  describe ".popular_with_pagination" do
    pending "add examples"
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

  describe "#init_tier" do
    it "should execute before save callback and assign tier id" do
      image.tier_id.should == 1
    end
  end

   describe "#sample_product_price" do
    pending "add examples"
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

  describe "#promote!" do
    it "should be true" do
      image.promote!
      image.promoted.should be_true
    end
  end

  describe "#demote!" do
    it "should be true" do
      image.demote!.should be_true
    end
  end

  describe "sample_product_price" do
    pending "add"
  end
end

