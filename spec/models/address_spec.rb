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

end
