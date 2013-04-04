require 'spec_helper'

describe Product do
  let(:product) { create(:product) }
  let(:size) { create(:size) }

  it { should belong_to(:moulding) }
  it { should belong_to(:size) }

  it { should validate_presence_of(:moulding) }
  it { should validate_presence_of(:size) }
  it { should validate_presence_of(:tier1_price) }
  it { should validate_presence_of(:tier2_price) }
  it { should validate_presence_of(:tier3_price) }
  it { should validate_presence_of(:tier4_price) }
  it { should validate_presence_of(:tier1_commission) }
  it { should validate_presence_of(:tier2_commission) }
  it { should validate_presence_of(:tier3_commission) }
  it { should validate_presence_of(:tier3_commission) }
  it { should validate_presence_of(:tier4_commission) }

  describe ".in_sizes" do
    context "with matched sizes" do
      it "should return appropriate products" do
        product1 = create(:product, :size_id => size.id)
        Product.in_sizes([size.id]).should == [product1]
      end
    end

    context "with unmatched sizes" do
      it "should return blank array" do
        Product.in_sizes([size.id]).should == []
      end
    end
  end

  describe "#price_for_tier" do
    it "should return price for appropriate tier" do
      product1  = create(:product, :tier4_price => 500.0)
      img = create(:image, :tier_id => 4)
      product1.price_for_tier(img.tier_id).should == 500.0
    end
  end

  describe "#commission_for_tier" do
    it "should return commission for appropriate tier" do
      product1  = create(:product, :tier4_commission => 100.0)
      img = create(:image, :tier_id => 4)
      product1.commission_for_tier(img.tier_id).should == 100.0
    end
  end

  describe "#associated_with_any_orders?" do
    context "with line item" do
      it "should be true" do
        line_item = create(:line_item, :product_id => product.id)
        product.associated_with_any_orders?.should be_true
      end
    end

    context "without line item" do
      it "should be false" do
        product.associated_with_any_orders?.should be_false
      end
    end
  end

end
