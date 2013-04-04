require 'spec_helper'

describe Moulding do
  let(:moulding) { create(:moulding) }

  it { should respond_to(:name) }

  it { should validate_presence_of(:name) }

  it "has a default sort of moulding ids" do
    moulding1 = create(:moulding)
    klass.all.should == [moulding1]
  end

  describe ".in_product" do
    it "should return appropriate moulding" do
      product = create(:product, :moulding_id => moulding.id)
      Moulding.in_product.should == [moulding]
    end
  end

end
