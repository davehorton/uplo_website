require "spec_helper"

describe UserMailer do
  let(:user) { create(:user) }

  before { ActionMailer::Base.deliveries = [] }

  describe "banned_user_email" do
    let(:mail) { UserMailer.banned_user_email(user.id) }

    it "should send banned user email after an user is banned" do
      user.ban!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should match email details" do
      mail.subject.should eq("Your account has been suspended.")
    end

    it "renders the body" do
      mail.body.encoded.should have_content("#{user.fullname}")
      mail.body.encoded.should have_selector("p", :text => "We are sorry that your account has been suspended because you have too many flagged images.")
    end
  end

  describe "removed_user_email" do
    let(:mail) { UserMailer.removed_user_email(user.id) }

    it "should send removed user email after an user is banned" do
      user.remove!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should match email details" do
      mail.subject.should eq("Your account has been removed from UPLO.")
    end

    it "renders the body" do
      mail.body.encoded.should have_content("#{user.fullname}")
      mail.body.encoded.should have_selector("p", :text => "We are very sorry that your account has been removed from UPLO by the administrator.")
    end
  end

  describe "deliver_welcome_email" do
    let(:mail) { UserMailer.deliver_welcome_email(user) }

    it "should send welcome email after a new user has confirmed their account" do
      user.confirm!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should match email details" do
      mail.subject.should eq("Welcome to UPLO!!")
    end

    it "renders the body" do
      mail.body.encoded.should have_selector("p", :text => "Greetings!")
      mail.body.encoded.should have_selector("p", :text => "YOU have become a part of UPLO!")
      mail.body.encoded.should have_link("Alright, what are you waiting for, click here get started now!", :href => "#{intro_url}")
    end
  end

  describe "flagged_image_reinstated_email" do
    let(:image) { create(:image_with_image_flags) }
    let(:mail) { UserMailer.flagged_image_reinstated_email(user.id, image.id) }

    it "should send reinstate email after an image is flagged" do
      image.reinstate!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should match email details" do
      mail.subject.should eq("Your image has been reinstated.")
    end

    it "renders the body" do
      mail.body.encoded.should have_link("Test Image", :href => browse_image_url(image))
    end
  end

  describe "flagged_image_removed_email" do
    let(:image) { create(:image_with_image_flags) }
    let(:mail) { UserMailer.flagged_image_removed_email(user.id, image.id) }

    it "should remove a flagged image" do
      image.remove!
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "should match email details" do
      mail.subject.should eq("Your image has been removed.")
    end

    it "renders the body" do
      mail.body.encoded.should have_content("Hi #{user.fullname}, Your image \"Test Image\" has been removed by the administrator. Please contact support@uplo.com if you have any questions. Best regards.")

    end
  end
end

