require 'spec_helper'

describe Address do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:street_address) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:zip) }

  describe "#in_new_york?" do
    context "when state is not New York" do
      subject { create(:address, :state => "new jersey") }
      it "should be false" do
        subject.in_new_york?.should be_false
      end
    end

    context "when state is new york" do
     subject { create(:address, :state => "new york") }
      it "should be true" do
        subject.in_new_york?.should be_true
      end
    end

    context "when state is new york in initials" do
      subject { create(:address, :state => "ny") }
      it "should be true" do
        subject.in_new_york?.should be_true
      end
    end
  end

  describe "cc_address_attributes" do
    context "when optional address present" do
      it "should return proper address" do
        address1 = create(:address, :street_address => "lincoln street", :optional_address => "test", :city => "kolkata", :state => "test1", :zip => 100000)
        address1.cc_address_attributes.should == {:address=>"lincoln street, test", :city=>"kolkata", :state=>"test1", :zip=>100000}
      end
    end

    context "when optional address not present" do
      it "should return proper address" do
        address1 = create(:address, :street_address => "lincoln street", :city => "kolkata", :state => "test1", :zip => 100000)
        address1.cc_address_attributes.should == {:address=>"lincoln street", :city=>"kolkata", :state=>"test1", :zip=>100000}
      end
    end
  end

  describe "#full_address" do
    it "should return proper address" do
      new_address = create(:address, :city => "City1", :state => "abc", :country => "India", :street_address => "Street1", :zip => "111111")
      new_address.full_address.should == "Street1, City1, abc, 111111, India"
    end
  end

end
