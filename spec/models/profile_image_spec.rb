require 'spec_helper'

describe ProfileImage do
  let(:profile_image) { create(:real_profile_image) }

  subject { profile_image }

  it { should belong_to(:user) }
  it { should belong_to(:source) }

  it { should have_attached_file(:avatar) }
  it { should validate_attachment_presence(:avatar) }
  it { should validate_attachment_content_type(:avatar).allowing('image/jpeg', 'image/jpg') }
  it { should validate_attachment_size(:avatar).less_than(75.megabytes) }

  describe "#set_as_default" do
    context "execute after create callback" do
      it "should update default to true" do
        user = create(:user)
        photo = create(:real_profile_image, :user_id => user.id)
        photo1 = create(:real_profile_image, :user_id => user.id)
        photo1.default.should be_true
        photo.default.should be_true
      end
    end
  end

  describe "#s3_expire_time" do
    it "should return proper time" do
      profile_image.s3_expire_time.should ==  "#{Time.zone.now.beginning_of_day.since 25.hours}"
    end
  end

  describe "#current_avatar?" do
    context "without default" do
      it "should return false" do
        profile_image.update_attribute(:default, false)
        profile_image.current_avatar?.should be_false
      end
    end

    context "with default" do
      it "should return true" do
        profile_image.update_attribute(:default, true)
        profile_image.current_avatar?.should be_true
      end
    end
  end

end
