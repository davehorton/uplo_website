require 'spec_helper'

describe Product do
  let(:product) { create(:product) }
  let(:size) { create(:size) }

  it { should belong_to(:moulding) }
  it { should belong_to(:size) }

  it { should have_many(:product_options) }

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

  it { should accept_nested_attributes_for(:product_options) }

  it "has a private_gallery scope" do
    product1 = create(:product, :private_gallery => true)
    klass.all.should == [product1]
  end

  it "has a public_gallery scope" do
    product
    product1 = create(:product, :public_gallery => true)
    klass.all.should == [product, product1]
  end

  describe ".for_sizes" do
    context "with matched sizes" do
      it "should return appropriate products" do
        product1 = create(:product, :size_id => size.id)
        Product.for_sizes([size.id]).should == [product1]
      end
    end

    context "with unmatched sizes" do
      it "should return blank array" do
        Product.for_sizes([size.id]).should == []
      end
    end
  end

  describe ".for_rectangular_sizes" do
    context "with matched sizes" do
      it "should return appropriate products" do
        product1 = create(:product, :size_id => size.id)
        Product.for_rectangular_sizes.should == [product1]
      end
    end

    context "with unmatched sizes" do
      it "should return blank array" do
        Product.for_rectangular_sizes.should == []
      end
    end
  end

  describe ".for_square_sizes" do
    context "with matched sizes" do
      it "should return appropriate products" do
        size1 = create(:square_size)
        product1 = create(:product, :size_id => size1.id)
        Product.for_square_sizes.should == [product1]
      end
    end

    context "with unmatched sizes" do
      it "should return blank array" do
        Product.for_square_sizes.should == []
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

  describe "display_name" do
    it "should return proper name" do
      product.display_name.should == "#{product.size.to_name} - #{product.moulding.name}"
    end
  end

end
