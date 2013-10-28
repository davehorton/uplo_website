require 'spec_helper'

describe Product do
  let(:product) { create(:product, :tier1_price => 400) }
  let(:size) { create(:size) }

  it { should belong_to(:moulding) }
  it { should belong_to(:size) }

  it { should have_many(:product_options) }
  it { should have_many(:line_items) }

  it { should validate_presence_of(:moulding) }
  it { should validate_presence_of(:size) }
  it { should validate_presence_of(:tier1_price) }
  it { should validate_presence_of(:tier2_price) }
  it { should validate_presence_of(:tier3_price) }
  it { should validate_presence_of(:tier4_price) }
  it { should validate_presence_of(:tier5_price) }
  it { should validate_presence_of(:tier1_commission) }
  it { should validate_presence_of(:tier2_commission) }
  it { should validate_presence_of(:tier3_commission) }
  it { should validate_presence_of(:tier3_commission) }
  it { should validate_presence_of(:tier4_commission) }
  it { should validate_presence_of(:tier5_commission) }

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

  it "should have a tier3_price" do
    product
    product.tier3_price.should_not be_zero
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
      product.update_attribute(:tier4_price, 500.0)
      img = create(:image, :tier_id => 4)
      product.price_for_tier(img.tier_id).should == 500.0
    end

    context "when user owns image" do
      it "subtracts commission from total price" do
        product.update_attributes(:tier4_price => 500.0, :tier4_commission => 10)
        img = create(:image, :tier_id => 4)
        product.price_for_tier(img.tier_id, img.user).should == 450.0
      end
    end
  end

  describe "#commission_for_tier" do
    it "should return commission for appropriate tier" do
      product.update_attribute(:tier4_commission, 100.0)
      img = create(:image, :tier_id => 4)
      product.commission_for_tier(img.tier_id).should == 100.0
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

  describe "#recalculate_line_items" do
    context "with purchased orders" do
      it "should not change the price for finalized line items" do
        order = create(:order, :status => "completed")
        finalized_line_item = create(:line_item, :order => order, :product => product)
        product.update_attribute(:tier1_price, 100)
        finalized_line_item.price.to_f.should == 400
      end
    end

    context "without purchased orders" do
      it "should change the price for line items in cart and update order total" do
        order = create(:order, :status => "shopping")
        recent_line_item = create(:line_item, :order => order, :product => product)
        product.update_attribute(:tier1_price, 100)
        recent_line_item.reload.price.to_f.should == 100
      end
    end
  end

end
