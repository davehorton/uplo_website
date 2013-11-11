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
        Gallery.search_scope("te").should == [gallery]
      end
    end

    context "when query description present" do
      it "should return searched results" do
        gallery.update_attribute(:description, "hello")
        Gallery.search_scope("Hel").should == [gallery]
        Gallery.search_scope("abc").should == []
      end
    end

    context "when query keyword present" do
      it "should return searched results" do
        gallery.update_attribute(:keyword, "public")
        Gallery.search_scope("publ").should == [gallery]
        Gallery.search_scope("private").should == []
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

  describe "#last_update" do
    it "should return proper formatted time" do
      gallery.last_update.should == gallery.updated_at.strftime('%B %Y')
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
         subject.cover_image.should == subject.images.last
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

  describe "#accessible?" do
    let!(:user) { create(:user) }
    let!(:admin) { create(:user, admin: true) }
    let!(:another_user) { create(:user_with_gallery) }
    let!(:gallery) { another_user.galleries.first }

    context "public gallery" do
      it "should return true if user not logged in" do
        gallery.accessible?.should be_true
      end

      it "should return true if user logged in" do
        gallery.accessible?(user).should be_true
        gallery.accessible?(another_user).should be_true
      end
    end

    context "private gallery" do

      before do
        gallery.update_attribute(:permission, :private)
      end

      context "should be true" do
        it "when gallery is owned" do
          gallery.accessible?(another_user).should be_true
        end

        it "when logged in user is admin" do
          gallery.accessible?(admin).should be_true
        end

        it "when have invitations" do
          gallery.accessible?(user).should be_false

          gallery_invitation = create(:gallery_invitation, user: user, gallery: gallery)
          gallery.accessible?(user).should be_true
        end
      end

      context "should be false" do
        it "when no logged in user" do
          gallery.accessible?.should be_false
        end
      end
    end
  end

end


