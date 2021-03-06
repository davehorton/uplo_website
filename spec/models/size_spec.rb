require 'spec_helper'

describe Size do
  let(:size){ create(:size, :width => 50, :height => 45) }

  it { should validate_presence_of(:height) }
  it { should validate_presence_of(:width) }

  describe "#to_name" do
    it "should return value" do
      size.to_name.should == "45x50"
    end
  end

  describe "#to_recommended_pixels" do
    it "should return proper result" do
      size.to_recommended_pixels.should == "6750x7500"
    end
  end

  describe "to_a" do
    it "should return array" do
      size.to_a.should == [45, 50]
    end
  end

  describe "#aspect_ratio" do
    it "should return proper value" do
      size.aspect_ratio.should == 1.1111111111111112
    end
  end

  describe "#rectangular" do
    context "when width not equal to height" do
      it "should return true" do
        size.rectangular?.should be_true
      end
    end
    context "when width equal to height" do
      it "should return false" do
        new_size = create(:size, :width => 50, :height => 50)
        new_size.rectangular?.should be_false
      end
    end
  end

  describe "#square?" do
    context "when width not equal to height" do
      it "should return false" do
        size.square?.should be_false
      end
    end
    context "when width equal to height" do
      it "should return true" do
        new_size = create(:size, :width => 50, :height => 50)
        new_size.square?.should be_true
      end
    end
  end

  describe "#dpi" do
    it "should return proper format" do
      size.dpi.should == 150.0
    end
  end

end
