require 'spec_helper'

describe User do
  let(:user) { create(:user) }

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
  it { should ensure_length_of(:cvv).is_at_least(3).is_at_most(4) }
  it { should validate_numericality_of(:cvv).only_integer }
  it { should validate_numericality_of(:card_number).only_integer }
  it { should validate_format_of(:website) }

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
    a = create(:user,:username => "rose" )
    b = create(:user, :username => "jane")
    klass.all.should == [b, a]
  end

  it "has a removed_users scope" do
    user1 = create(:user, :removed => true)
    User.removed_users.should == [user1]
  end

  it "has a not_removed scope" do
    User.not_removed.should == [user]
  end

  it "has a flagged users scope" do
    new_user = create(:user, :banned => true, :removed => false)
    User.flagged_users.should == [new_user]
  end

  it "has a confirmed scope" do
    one_user = create(:user, :confirmed_at => "04-04-2012")
    User.confirmed.should == [one_user]
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
    context "with num of likes as sort field" do
      it "should display output" do
        user1 = create(:user, :image_likes_count=> 3)
        user2 = create(:user, :image_likes_count=> 2)
        user3 = create(:user, :image_likes_count => 1)
        User.paginate_and_sort({ :page => 1, :per_page => 2, :sort_field => "num_of_likes" }).should == [user1, user2]
      end
    end
  end

  describe ".find_first_by_auth_conditions" do
    pending "add examples"
  end

  describe "#to_param" do
    it "should parameterize" do
      new_user = create(:user, :username => "sathi")
      new_user.to_param.should == "#{new_user.id}-#{new_user.username.parameterize}"
    end
  end

  describe ".remove_flagged_users" do
  end

  describe ".reinstate_flagged_users" do
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
        user1 = create(:user, :confirmed_at => "02-04-2013")
        user1.joined_date.should == user1.confirmed_at.strftime('%B %Y')
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

  end
  describe "update_profile" do
    pending "add examples"
  end

  describe "#male?" do
    it "should return true when gender matches" do
      user1 = create(:user, :gender => 0)
      user1.male?.should be_true
    end
  end

  describe "#has_follower?" do
    context "when followed" do
      it "should return true" do
        another_user = create(:user)
        user_follow = create(:user_follow, :user_id => user.id, :followed_by => another_user.id)
        user.has_follower?(another_user.id).should be_true
      end
    end
    context "when not followed" do
      it "should return false" do
        another_user = create(:user)
        user_follow = create(:user_follow, :user_id => user.id, :followed_by => user.id)
        user.has_follower?(another_user.id).should be_false
      end
    end
  end

  describe "has_profile_photo?" do
  end

  describe "gender_string" do
    context "with gender" do
      it "should return male" do
        user1 = create(:user, :gender => 0)
        user1.gender_string.should == "Male"
      end
    end
    context "without gender" do
      it "should return female" do
        user.gender_string.should == "Female"
      end
    end
  end

  describe "#recent_empty_order" do
    context "with orders" do
      it "should return appropriate order" do
        user1 = create(:user_with_orders)
        order1 = user1.orders.last
     #   user1.recent_empty_order.should == order1
      end
    end
    context "with orders" do
      it "should create a new order and return" do
        user1 = create(:user)
        user1.recent_empty_order.should == user1.orders.first
      end
    end
  end

  describe "#raw_sales" do
    context "with line items" do
      it "should return result" do
        image = create(:image, :user_id => user.id)
        new_order = create(:order, :transaction_status => "completed")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        #needs to be checked
        user.raw_sales.should == []
      end
    end
    context "without line items" do
      it "should return blank array" do
        user.raw_sales.should == []
      end
    end
  end

  describe "#images_pageview" do
    context "with images having pageview" do
      it "should return count" do
        user1 = create(:user_with_images)
        #needs to be checked
        user1.images_pageview.should == 0
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
      user1 = create(:user_with_images)
      user1.remove!
      puts user.images.count
     # user1.images.first.removed.should be_true
      user1.removed.should be_true
    end
  end

  describe "remove_flagged_images" do
    it "should remove associated flagged images" do
      image = create(:image_with_image_flags, :user_id => user.id)
      user.remove_flagged_images
      image.removed.should be_false
    end
  end

  describe "blocked?" do
    context "banned" do
      it "should return true" do
        user.update_attribute(:banned, true)
        user.blocked?.should be_true
      end
    end
    context "removed" do
      it "should return true" do
        user.update_attribute(:removed, true)
        user.blocked?.should be_true
      end
    end
  end

  describe "total_earn" do
    it "should calculate result" do
      another_user = create(:user)
      image = create(:image, :user_id => another_user.id)
      new_order = create(:order, :transaction_status => "completed")
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 35.0)
      another_user.total_earn.should == 200000.0
    end
  end

  describe "owned_amount" do
    it "should return amount" do
      another_user = create(:user, :withdrawn_amount => 100000.0)
      image = create(:image, :user_id => another_user.id)
      new_order = create(:order, :transaction_status => "completed")
      line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4, :price => 50, :commission_percent => 35.0)
      another_user.total_earn.should == 100000.0
    end
  end

end
