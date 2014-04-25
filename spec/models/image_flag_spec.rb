require 'spec_helper'

describe ImageFlag do
  let(:image_flag) { create(:image_flag, :flag_type => 3) }

  it { should belong_to(:image) }
  it { should belong_to(:reporter) }

  it { should validate_presence_of(:image_id).with_message(/cannot be blank/) }
  it { should validate_presence_of(:reported_by).with_message(/cannot be blank/) }
  it { should ensure_length_of(:description).with_message(/cannot excced 255 characters/) }


  describe ".flag_type_string" do
    context "when number equals to num of flag_type hash" do
      it "should return name of flag type" do
        ImageFlag.flag_type_string(1).should == "Terms of Use Violation"
     end
    end

    context "when number does not equal to num of flag_type hash" do
      it "should return blank" do
        ImageFlag.flag_type_string(5).should be_blank
      end
    end
  end

  describe ".nudity?" do
    context "when flag_type does not match" do
      it "should return false" do
        new_image_flag = create(:image_flag, :flag_type => 1)
        new_image_flag.nudity?.should be_false
      end
    end

    context "when flag_type  matches" do
      it "should return true" do
        image_flag.nudity?.should be_true
      end
    end
  end

  describe "description_presence validator" do
    context "with description" do
      it "should return nil" do
        image_flag.description_presence.should be_nil
      end
    end

    context "without description" do
      it "should have an error when flag type is terms_of_use_violation" do
        image_flag.flag_type = ImageFlag::FLAG_TYPE['terms_of_use_violation']
        image_flag.description = nil
        image_flag.valid?
        expect(image_flag.errors_on(:description)).to include(I18n.t("image_flag.missing_description_terms_of_use_violation"))
      end

      it "should have an error when flag type is copyright" do
        image_flag.flag_type = ImageFlag::FLAG_TYPE['copyright']
        image_flag.description = nil
        image_flag.valid?
        expect(image_flag.errors_on(:description)).to include(I18n.t("image_flag.missing_description_copyright"))
      end

      it "should not have an error when flag type is nudity" do
        image_flag.flag_type = ImageFlag::FLAG_TYPE['nudity']
        image_flag.description = nil
        image_flag.valid?
        expect(image_flag).to have(:no).errors_on(:description)
      end

      it "should have an error when flag type is unknown" do
        image_flag.flag_type = 43
        image_flag.description = nil
        image_flag.valid?
        expect(image_flag.errors_on(:description)).to include("Unknown violation type!")
      end
    end
  end

  describe "reported_date" do
    it "should be in proper format" do
      image_flag.reported_date.should == image_flag.created_at.strftime('%b %d, %Y')
    end
  end

end
