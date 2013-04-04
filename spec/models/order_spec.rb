require 'spec_helper'

describe Order do
  let(:order) { create(:order) }

  it { should belong_to(:user) }
  it { should belong_to(:shipping_address) }
  it { should belong_to(:billing_address) }

  it { should have_one(:cart) }
  it { should have_many(:line_items) }
  it { should have_many(:images).through(:line_items) }

  it { should accept_nested_attributes_for(:billing_address) }
  it { should accept_nested_attributes_for(:shipping_address) }

  it { should ensure_length_of(:cvv).is_at_least(3).is_at_most(4) }
  it { should validate_numericality_of(:cvv).only_integer }
  it { should validate_numericality_of(:card_number).only_integer }

  it "has a completed scope" do
    order1 = create(:order, :transaction_status => "completed")
    Order.completed.should == [order1]
  end

  describe "#update_tax_by_state" do
    context "when no has tax" do
      it "should update tax to zero" do
        order.update_tax_by_state
        order.tax.should be_zero
      end
    end

    context "with with shipping address" do
      it "should update tax" do
        shipping_address = create(:shipping_address, :state => "new york")
        order1 = create(:order_with_line_items, :shipping_address_id => shipping_address.id)
        line_item = order1.line_items.first
        line_item.update_attributes(:price => 500, :quantity => 4)
        order1.update_tax_by_state
        order1.tax.should == 355.0
      end
    end
  end

  describe "#compute_image_total" do
    context "with line items having price" do
      it "should return result" do
        order1 = create(:order_with_line_items)
        line_item = order1.line_items.first
        line_item.update_attributes(:price => 500, :quantity => 4)
        order1.compute_image_total.to_i.should == 4000
      end
    end

    context "without line items" do
      it "should return result" do
        order.compute_image_total.should be_zero
      end
    end
  end

  describe "#compute_totals" do
    context "with line items" do
      it "should return result" do
        order1 = create(:order_with_line_items)
        line_item = order1.line_items.first
        line_item.update_attributes(:price => 500, :quantity => 4)
        order1.compute_totals
        order1.price_total.to_i.should == 4000
        order1.order_total.to_i.should == 4015
      end
    end

    context "without line items" do
      it "should return result" do
        order.compute_totals
        order.price_total.should be_zero
        order.order_total.to_i.should == 15
      end
    end
  end

  describe "#transaction_completed?" do
    context "with completed status" do
      it "should return true" do
        order1 = create(:order, :transaction_status => "completed")
        order1.transaction_completed?.should be_true
      end
    end

    context "with not completed status" do
      it "should return false" do
        order.transaction_completed?.should be_false
      end
    end
  end

  describe "#finalize_transaction" do
    pending "method seems broken"
  end

  describe "before create callback init_transaction_date" do
    it "should assign transaction date" do
      order1 = create(:order, :transaction_date => "")
      order1.transaction_date.should_not be_blank
    end
  end

end
