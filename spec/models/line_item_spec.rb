require 'spec_helper'

describe LineItem do
  let(:image) { create(:image, :tier_id => 1) }
  let(:empty_line_item) { create(:line_item, :image_id => image.id) }

  it { should belong_to(:image) }
  it { should belong_to(:product) }
  it { should belong_to(:order) }

  it { should validate_numericality_of(:quantity) }

  describe ".sold_items" do
    context "with matching orders" do
      it "should return appropriate line items" do
        new_order = create(:order, :transaction_status => "completed")
        line_item1 = create(:line_item, :image_id => image.id, :order_id => new_order.id)
        LineItem.sold_items.should == [line_item1]
      end
    end

    context "without matching orders" do
      it "should return blank array" do
        LineItem.sold_items.should == []
      end
    end
  end

  describe "total_price" do
    it "should calculate total" do
      empty_line_item.update_attributes(:tax => 10.0, :quantity => 4, :price => 500)
      empty_line_item.total_price.should == 2000
    end
  end

  describe "#calculate_totals" do
    context "executing before_save calback" do
      it "should calculate result" do
        empty_line_item.price.should == 500
        empty_line_item.tax.should be_zero
        empty_line_item.commission_percent.should == 100
      end
    end
  end

end

