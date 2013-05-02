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
      it "should return searched results" do
        gallery.update_attribute(:name, "test")
        Gallery.search_scope("---\n- test\n").should == [gallery]
      end
    end

    context "when query description present" do
      it "should return searched results" do
        gallery.update_attribute(:description, "hello")
        Gallery.search_scope("---\n- hello;").should == [gallery]
        Gallery.search_scope("---\n- abc..;").should == []
      end
    end

    context "when query keyword present" do
      it "should return searched results" do
        gallery.update_attribute(:keyword, "public")
        Gallery.search_scope("---\n- ...public;").should == [gallery]
        Gallery.search_scope("---\n- private..;").should == []
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
         image1 = subject.images.last
         subject.cover_image.should == image1
       end
     end
   end

   describe "updated_at_string" do
     it "should check proper format" do
       gallery.updated_at_string.should == gallery.updated_at.strftime("%m/%d/%y")
     end
   end

  describe "#get_images_without" do
    context "when ids not in array format" do
      it "should return blank" do
        gallery.get_images_without(1).should == []
      end
    end
    context "when ids is blank" do
      it "should return blank array" do
        gallery.get_images_without([]).should == []
      end
    end
    context "when ids are present" do
      it "should return matched result" do
        new_gallery = create(:gallery_with_images)
        @img1 = new_gallery.images.first
        @img2 = new_gallery.images.last
        new_gallery.get_images_without([@img1.id]).should == [@img2]
      end
    end
  end

  describe "#is_public?" do
    context "when permission public" do
      it "should return true" do
        gallery.is_public?.should be_true
      end
    end

    context "when permission public" do
      it "should return true" do
        gallery.update_attribute(:permission, "private")
        gallery.is_public?.should be_false
      end
    end
  end

end


