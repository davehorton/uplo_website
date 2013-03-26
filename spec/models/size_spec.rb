require 'spec_helper'

describe Size do
  let(:size){ create(:size) }

  it { should validate_presence_of(:height) }
  it { should validate_presence_of(:width) }

  it "should check #to_name" do
    size.to_name.should == "45x50"
  end

  it "should check #to_a" do
    size.to_a.should == [45, 50]
  end

  describe "#rectangular" do
    context "when width not equal to height" do
      it "should return true" do
        size.rectangular?.should == true
      end
    end
    context "when width equal to height" do
      it "should return false" do
        new_size = create(:size, :width => 50)
        new_size.rectangular?.should == false
      end
    end
  end

  describe "square?" do
    context "when width not equal to height" do
      it "should return false" do
        size.square?.should == false
      end
    end
    context "when width equal to height" do
      it "should return true" do
        new_size = create(:size, :width => 50)
        new_size.square?.should == true
      end
    end
  end

end
