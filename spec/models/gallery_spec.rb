require 'spec_helper'

describe Gallery do
  let(:gallery){ create(:gallery) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user) }

  it { should belong_to(:user) }
  it { should have_many(:images) }


  it "has a default sort of name_asc" do
    a = create(:gallery, :name => "john")
    b = create(:gallery, :name => "demo")
    klass.all.should == [b, a]
  end

  describe ".search_scope" do
    context "when query name present" do
      subject { create(:gallery_with_images) }
      it "should return searched results" do
        img1 =  subject.images.first
        img2 = subject.images.last
        Gallery.search_scope("---\n- demo\n- image\n").should == [[img1,  img2]]
      end
    end
    context "when query description present" do
      subject { create(:gallery_with_images) }
      it "should return searched results" do
        img1 =  subject.images.first
        img1.update_attribute(:description, "testing")
        Gallery.search_scope("---\n- testing").should == [[img1]]
      end
    end
    context "when query keyword present" do
      subject { create(:gallery_with_images) }
      it "should return searched results" do
        img1 =  subject.images.first
        img1.update_attribute(:keyword, "secret")
        Gallery.search_scope("---\n- secret\n").should == [[img1]]
        Gallery.search_scope("---\n- demo\n- keyword\n").should == [[]]
      end
    end
  end

  describe "#total_images" do
    context "with images" do
      subject { create(:gallery_with_images) }
      it "should show total" do
        subject.total_images.should == 2
      end
    end
    context "without images" do
      it "should show total" do
        gallery.total_images.should be_zero
      end
    end
  end

  describe "#cover_image" do
    context "when conditions met" do
      it "should get cover image" do
        image = create(:image, :gallery_id => gallery.id)
        gallery.cover_image.should == image
      end
    end
    context "when conditions are not met" do
      subject { create(:gallery_with_images_without_cover) }
      it "should set cover image" do
        subject.images.last.update_attribute(:gallery_cover, false)
        image1 = subject.images.first
        subject.cover_image.should == image1
      end
    end
  end

  describe "updated_at_string" do
    it "should check proper format" do
      gallery.updated_at_string.should == gallery.updated_at.strftime("%m/%d/%y")
    end
  end

end


