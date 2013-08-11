require 'spec_helper'

describe User do
  let(:user) { create(:user) }
  let(:another_user) { create(:user_with_gallery) }
  let(:image) { create(:image) }

  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:force_submit) }
  it { should respond_to(:login) }
  it { should respond_to(:skip_state_changed_tracking) }

  it { should belong_to(:shipping_address) }
  it { should belong_to(:billing_address) }
  it { should have_many(:galleries) }
  it { should have_many(:public_galleries) }
  it { should have_many(:images)}
  it { should have_many(:public_images).through(:public_galleries)}
  it { should have_many(:profile_images)}
  it { should have_many(:image_likes) }
  it { should have_many(:source_liked_images).through(:image_likes)}
  it { should have_many(:comments)}
  it { should have_many(:devices) }
  it { should have_many(:orders) }
  it { should have_many(:user_followers)}
  it { should have_many(:followers).through(:user_followers)}
  it { should have_many(:user_followings)}
  it { should have_many(:followed_users).through(:user_followings)}
  it { should have_many(:friends_images).through(:followed_users)}

  it { should have_one(:cart)}

  it { should accept_nested_attributes_for(:billing_address) }
  it { should accept_nested_attributes_for(:shipping_address) }

  it { should validate_presence_of(:first_name).with_message(/cannot be blank/) }
  it { should validate_presence_of(:last_name).with_message(/cannot be blank/) }
  it { should validate_presence_of(:username).with_message(/cannot be blank/) }
  it { should validate_presence_of(:password) }
  it { should validate_confirmation_of(:password) }
  it { should ensure_length_of(:first_name).is_at_least(1).is_at_most(30) }
  it { should validate_confirmation_of(:paypal_email).with_message(/should match confirmation/) }
  it { should allow_value('www.example.com').for(:website) }
  it { should_not allow_value('wrong#?.format').for(:website) }

  describe "validations" do
    before(:each) do
      @attr = {
        :first_name => "Tester",
        :last_name => "Hacker",
        :username => "tester",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
      }
    end

    it "should create a new instance given a valid attribute" do
      user1 = User.new(@attr)
      user1.should be_valid
    end

    it "should require an email address" do
      no_email_user = User.new(@attr.merge(:email => ""))
      no_email_user.should_not be_valid
    end

    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end

    it "should reject duplicate email addresses" do
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end

    it "should reject email addresses identical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  end

  it "has a default sort of username_asc" do
    a = create(:user, :username => "rose" )
    b = create(:user, :username => "jane")
    klass.all.should == [b, a]
  end

  it "has a removed_users scope" do
    user.update_attribute(:removed, true)
    User.removed_users.should == [user]
  end

  it "has a not_removed scope" do
    User.not_removed.should == [user]
  end

  it "has a flagged users scope" do
    user = create(:user, :banned => true, :removed => false)
    User.flagged_users.should == [user]
  end

  it "has a confirmed scope" do
    user.update_attribute(:confirmed_at, "04-04-2012")
    User.confirmed.should == [user]
  end

  it "has a reinstate_ready_users scope" do
    another_user.update_attribute(:banned, true)
    User.reinstate_ready_users.should == [another_user]
  end

  describe ".search_scope" do
    context "when query first name present" do
      it "should return searched results" do
        user1 = create(:user, :first_name => "rose")
        User.search_scope("---\n- rose\n").should == [user1]
        User.search_scope("---\n- rosy\n").should == []
      end
    end

    context "when query last name present" do
      it "should return searched results" do
        user1 = create(:user, :last_name => "doe")
        User.search_scope("---\n- doe;").should == [user1]
        User.search_scope("---\n- abc..;").should == []
      end
    end

    context "when query username present" do
      it "should return searched results" do
        user1 = create(:user, :username => "julia")
        User.search_scope("---\n- ...julia;").should == [user1]
        User.search_scope("---\n- private..;").should == []
      end
    end

    context "when query email present" do
      it "should return searched results" do
        pending "search with email seems broken"
      end
    end
  end

  describe ".paginate_and_sort" do
    context "without sort_field" do
      it "should display output" do
        user1 = create(:user, :username => "rob")
        user2 = create(:user, :username => "steve")
        user3 = create(:user, :username => "augustin")
        User.paginate_and_sort({ :page => 1, :per_page => 2 }).should == [user3, user1]
      end
    end

    context "with sign_up date as sort field" do
      it "should display output" do
        users = create_list(:user, 10)
        User.paginate_and_sort({ :page => 1, :per_page => 5, :sort_field => "signup_date" }).should == users.reverse.first(5)
      end
    end

    context "with username as sort field" do
      it "should display output" do
        user1 = create(:user, :username => "test")
        user.update_attribute(:username , "demo")
        User.paginate_and_sort({ :page => 1, :per_page => 2, :sort_field => "username"}).should == [user1, user]
      end
    end

    context "with num of likes as sort field" do
      it "should display output" do
        user1 = create(:user, :image_likes_count=> 3)
        user2 = create(:user, :image_likes_count=> 2)
        user3 = create(:user, :image_likes_count => 1)
        User.paginate_and_sort({ :page => 1, :per_page => 2, :sort_field => "num_of_likes" }).should == [user1, user2]
      end
    end
  end

  describe "#to_param" do
    it "should parameterize" do
      new_user = create(:user, :username => "sathi")
      new_user.to_param.should == "#{new_user.id}-#{new_user.username.parameterize}"
    end
  end

  describe ".remove_flagged_users" do
    context "when banned" do
      it "should update removed attribute" do
        another_user.update_attribute(:banned, true)
        User.remove_flagged_users.should == [another_user]
        another_user.removed.should be_false
      end
    end

    context "when not banned" do
      it "should update removed attribute" do
        User.remove_flagged_users.should == []
      end
    end
  end

  describe ".reinstate_flagged_users" do
    context "when banned" do
      it "should return banned true" do
        another_user.update_attribute(:banned, true)
        User.reinstate_flagged_users.should == [another_user]
        another_user.banned.should be_true
      end
    end

    context "when not banned" do
      it "should return blank array" do
        User.reinstate_flagged_users.should == []
      end
    end
  end

  describe "#liked_images" do
    context "with likes" do
      it "should return result" do
        image = create(:image)
        img_like = create(:image_like, :user_id => user.id, :image_id => image.id)
        user.liked_images.should == [image]
      end
    end
  end

  describe "#joined_date" do
    context "without confirmed at" do
      it "should return blank" do
        user.update_attribute(:confirmed_at, nil)
        user.joined_date.should be_blank
      end
    end

    context "with confirmed at" do
      it "should return result" do
        user.update_attribute(:confirmed_at, "02-04-2013")
        user.joined_date.should == user.confirmed_at.strftime('%B %Y')
      end
    end
  end

  describe "#fullname" do
    it "should return result" do
      user1 = create(:user, :first_name => "john", :last_name => "doe")
      user1.fullname.should == "john doe"
    end
  end

  describe "#friendly_email" do
    it "should generate email address including fullname" do
      new_user = create(:user, :first_name => "john", :last_name => "doe")
      new_user.friendly_email.should == "john doe <#{new_user.email}>"
    end
  end

  describe "#birthday" do
    context "when date is a string" do
      it "should save birthday" do
        user.birthday=("03/04/2013")
        user.birthday.should == "Mon, 04 Mar 2013".to_date
      end
    end

    context "when date is not a string" do
      it "should save birthday" do
        user.birthday=("Mon, 04 Mar 2013".to_date)
        user.birthday.should == "Mon, 04 Mar 2013".to_date
      end
    end
  end

  describe "update_profile" do
    context "when password present in params" do
      it "should update with password" do
        user1 = create(:user)
        user1.update_profile({:first_name => "mike", :password => "secret", :password_confirmation => "secret" })
        user1.first_name.should == "mike"
      end
    end

    context "when password not present in params" do
      it "should update without password" do
        user1 = create(:user, :username => "testing")
        user1.update_profile({ :first_name => "mike", :username => "mikyy", :last_name => "doe" } )
        user1.first_name.should == "mike"
        user1.last_name.should == "doe"
        user1.username.should == "testing"
      end
    end
  end

  describe "#male?" do
    it "should return true when gender matches" do
      user.update_attribute(:gender, 0)
      user.male?.should be_true
    end
  end

  describe "#has_follower?" do
    context "when followed" do
      it "should return true" do
        user_follow = create(:user_follow, :user_id => user.id, :followed_by => another_user.id)
        user.has_follower?(another_user.id).should be_true
      end
    end

    context "when not followed" do
      it "should return false" do
        user_follow = create(:user_follow, :user_id => user.id, :followed_by => user.id)
        user.has_follower?(another_user.id).should be_false
      end
    end
  end

  describe "has_profile_photo?" do
    context "with profile image" do
      it "should return true" do
        profile_photo = create(:profile_image, :user_id => user.id)
        user.has_profile_photo?(profile_photo).should be_true
      end
    end

    context "without profile image" do
      it "should return false" do
        profile_photo = create(:profile_image)
        user.has_profile_photo?(profile_photo).should be_false
      end
    end
  end

  describe "gender_string" do
    context "with gender" do
      it "should return male" do
        user.update_attribute(:gender, 0)
        user.gender_string.should == "Male"
      end
    end

    context "without gender" do
      it "should return female" do
        user.gender_string.should == "Female"
      end
    end
  end

  describe "#recent_empty_order" do
    context "without orders" do
      it "should create a new order and return" do
        user.recent_empty_order.should == user.orders.first
      end
    end
  end

  describe "#avatar" do
    context "when image is nil" do
      it "should return nil" do
        user.avatar.should be_nil
      end
    end

    context "when image is not nil" do
      it "should return image if it has source and source is removed" do
        profile_image = create(:profile_image, :user_id => user.id, :default => true)
        profile_image.source.update_attribute(:removed, true)
        user.avatar.should == nil
      end

      it "should return image if it has source and source is flagged" do
        profile_image = create(:profile_image, :user_id => user.id)
        img = profile_image.source
        img_flags = create_list(:image_flag, 2, :image_id => img.id)
        user.avatar.should == nil
      end

      it "should return image if conditions are met" do
        user1 = create(:user)
        profile_image = create(:profile_image, :user_id => user1.id)
        user1.avatar.should == profile_image
      end
    end
  end

  describe "#init_cart" do
    context "with cart nil" do
      it "should create a new cart" do
        user.init_cart
        user.cart.should == Cart.last
      end
    end

    context "with cart" do
      it "should return cart when order has no billing address" do
        cart = create(:cart, :user_id => user.id)
        cart.order.update_attribute(:billing_address_id, nil)
        user.init_cart
        cart.order.billing_address.first_name.should == user.billing_address.first_name
        cart.order.billing_address.last_name.should == user.billing_address.last_name
        cart.order.billing_address.street_address.should == user.billing_address.street_address
      end

      it "should update cart and return" do
        user1 = create(:user, :name_on_card => "test1", :card_type => "master card", :expiration => "january", :cvv => "234")
        cart = create(:cart, :user_id => user1.id)
        cart.order.update_attribute(:billing_address_id, nil)
        user1.init_cart
        cart.order.shipping_address.first_name == user1.shipping_address.first_name
        cart.order.shipping_address.last_name == user1.shipping_address.last_name
      end
    end
  end

  describe "#paid_items" do
    context "with image id" do
      it "should" do
        new_order = create(:completed_order, :user_id => user.id)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id)
        user.paid_items(image.id).should == [line_item]
      end
    end

    context "with blank image id" do
      it "should return blank array" do
        line_items = create_list(:line_item, 5)
        user.paid_items("").should == []
      end
    end
  end

  describe "#paid_items_number" do
    it "should calculate result" do
      new_order = create(:completed_order, :user_id => user.id)
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 5)
      user.paid_items_number(image.id).should == 5
    end
  end

  describe "total_paid" do
    it "should calculate result" do
      new_order = create(:completed_order, :user_id => user.id)
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 5, :price => 50.0, :tax => 10.0)
      user.total_paid(image.id).should == 2500
    end
  end

  describe "#sold_items" do
    context "with line items" do
      it "should return result" do
        another_user = create(:user_with_gallery)
        gallery1 = another_user.galleries.first
        image = create(:image, :gallery => gallery1)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        another_user.sold_items.should == [line_item]
      end
    end

    context "without line items" do
      it "should return blank array" do
        user.sold_items.should == []
      end
    end
  end

  describe "#monthly_sales" do
    it "should return calculated hash" do
      gallery1 = another_user.galleries.first
      image = create(:image, :gallery => gallery1)
      new_order = create(:completed_order, :transaction_date => "03-03-2012")
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 500, :commission_percent => 35.0)
      another_user.monthly_sales("01-03-2012").should == [{:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>2000.0}]
    end
  end

  describe "#total_sales" do
    context "with sold line items" do
      it "should return proper matched result" do
        gallery1 = another_user.galleries.first
        image = create(:image, :gallery => gallery1)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 5)
        another_user.total_sales.should be_a(Hash)
      end
    end

    context "without sold line items" do
      it "should return blank array" do
        user.total_sales.should == {:total_entries=>0, :data=>[]}
      end
    end
  end

  describe "#images_pageview" do
    context "with images having pageview" do
      it "should return count" do
        gallery1 = another_user.galleries.first
        img = create(:image, :pageview => 2, :gallery => gallery1)
        another_user.images_pageview.should == 2
      end
    end

    context "without images" do
      it "should return count" do
        user.images_pageview.should be_zero
      end
    end
  end

  describe "#ban" do
    it "should update banned attribute to true" do
      user.ban!
      user.banned.should be_true
    end
  end

  describe "#remove!" do
    it "should update removed attribute" do
      gallery1 = another_user.galleries.first
      img = create(:image, :gallery => gallery1)
      another_user.remove!
      img.removed.should be_false
      another_user.removed.should be_true
    end
  end

  describe "#remove_flagged_images" do
    it "should remove associated flagged images" do
      image = create(:image_with_image_flags, :user_id => user.id)
      user.remove_flagged_images
      image.removed.should be_false
    end
  end

  describe "#reinstate_flagged_images" do
    it "should reinstate" do
      gallery1 = another_user.galleries.first
      image = create(:image_with_image_flags, :gallery => gallery1)
      another_user.reinstate_flagged_images
      another_user.banned.should be_false
    end
  end

  describe "#reinstate" do
    context "when not ready for reinstating" do
      it "should return false" do
        gallery1 = another_user.galleries.first
        image = create(:image_with_five_image_flags, :gallery => gallery1)
        another_user.reinstate.should be_false
      end
    end

    context "when banned" do
      it "should return update banned atribute" do
        user.update_attribute(:banned, true)
        user.reinstate
        user.banned.should be_false
      end
    end
  end

  describe "#ban_threshold_met?" do
    context "user is not banned and not ready_for_reinstating?" do
      it "should return true" do
        another_user.update_attribute(:banned, false)
        gallery1 = another_user.galleries.first
        image = create(:image_with_five_image_flags, :gallery => gallery1)
        another_user.ban_threshold_met?.should be_true
      end
    end
  end

  describe "#ready_for_reinstating?" do
    it "should return true if flagged images length less than 3" do
      gallery1 = another_user.galleries.first
      image = create(:image_with_image_flags, :gallery => gallery1)
      another_user.ready_for_reinstating?.should be_true
    end
  end

  describe "#blocked?" do
    context "banned" do
      it "should return true" do
        user.update_attribute(:banned, true)
        user.blocked?.should be_true
      end
    end

    context "#removed" do
      it "should return true" do
        user.update_attribute(:removed, true)
        user.blocked?.should be_true
      end
    end
  end

  describe "#total_earn" do
    it "should calculate result" do
      gallery1 = another_user.galleries.first
      image = create(:image, :gallery => gallery1)
      new_order = create(:completed_order)
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 35.0)
      another_user.total_earn.should == 2000.0
    end
  end

  describe "#owned_amount" do
    it "should return amount" do
      another_user.update_attribute(:withdrawn_amount, 100.0)
      gallery1 = another_user.galleries.first
      image = create(:image, :gallery => gallery1)
      new_order = create(:completed_order)
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 35.0)
      another_user.owned_amount.should == 1900.0
    end
  end

  describe "#withdraw_paypal" do
    context "without paypal_email" do
      it "should raise error" do
        user.withdraw_paypal(500).should raise_error
      end
    end

    context "with paypal_email" do
      it "should raise error with amount less or equal to zero" do
        user.withdraw_paypal(0).should raise_error
      end

      it "should raise error with amount greater than owned_amount" do
        gallery1 = another_user.galleries.first
        image = create(:image, :gallery => gallery1)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 10.0)
        another_user.withdraw_paypal(5000000).should raise_error
      end
    end
  end

  describe "#owns_image?" do
    context "when image matches" do
      it "should return true" do
        gallery1 = another_user.galleries.first
        image = create(:image, :gallery => gallery1)
        another_user.owns_image?(image).should be_true
      end
    end

    context "when image does not match" do
      it "should return false" do
        user.owns_image?(image).should be_false
      end
    end
  end

  describe "#owns_gallery?" do
    context "when gallery matches" do
      it "should return true" do
        gallery1 = another_user.galleries.first
        another_user.owns_gallery?(gallery1).should be_true
      end
    end

    context "when gallery does not match" do
      it "should return false" do
        gallery = create(:gallery)
        user.owns_gallery?(gallery).should be_false
      end
    end
  end

  describe "#like_image" do
    it "should like an image" do
      user.like_image(image).should == { :image_likes_count => 1}
    end
  end

  describe "#unlike_image" do
    it "should unlike image" do
      gallery1 = another_user.galleries.first
      img = create(:image_with_image_flags, :gallery => gallery1)
      another_user.unlike_image(img).should == { :image_likes_count => 0}
    end
  end

  describe "#can_access?" do
    context "when gallery is owned" do
      it "should return true" do
        gallery1 = another_user.galleries.first
        another_user.can_access?(gallery1).should be_true
      end
    end

    context "when gallery is public" do
      it "should return true" do
        gallery1 = another_user.galleries.first
        gallery1.update_attribute(:permission, "public")
        another_user.can_access?(gallery1).should be_true
      end
    end

    context "when gallery has gallery invitations" do
      it "should return true" do
        gallery = create(:gallery)
        gallery_invitation = create(:gallery_invitation, :user_id => user.id)
        user.can_access?(gallery).should be_true
      end
    end
  end

  describe "#check_card_number" do
    context "when card number is valid" do
      it "should return true" do
        user.update_attribute(:card_number, "1")
        user.card_number.should == "1"
      end
    end

    context "when card number is not valid" do
      it "should raise error" do
        user1 = build(:user, :card_number => "235436478").should raise_error
      end
    end
  end

end
