require 'spec_helper'

describe Order do
  let(:empty_order) { create(:order) }
  let(:order) { create(:order_with_line_items) }

  it { should belong_to(:user) }
  it { should belong_to(:shipping_address) }
  it { should belong_to(:billing_address) }

  it { should have_one(:cart) }
  it { should have_many(:line_items) }
  it { should have_many(:images).through(:line_items) }

  it { should accept_nested_attributes_for(:billing_address) }
  it { should accept_nested_attributes_for(:shipping_address) }

  it "has a completed scope" do
    empty_order.update_attribute(:status, "completed")
    Order.completed.should == [empty_order]
  end

  describe "#update_tax_by_state" do
    context "when no has tax" do
      it "should update tax to zero" do
        empty_order.update_tax_by_state
        empty_order.tax.should be_zero
      end
    end

    context "with with shipping address" do
      it "should update tax" do
        shipping_address = create(:shipping_address, :state => "new york")
        order.shipping_address_id = shipping_address.id
        line_item = order.line_items.first
        line_item.price = 500
        line_item.update_attributes(:quantity => 4)
        order.update_tax_by_state
        order.tax.should == 355.0
      end
    end
  end

  describe "#compute_image_total" do
    context "with line items having price" do
      it "should return result" do
        order1 = create(:order_with_line_items)
        line_item = order1.line_items.first
        line_item.price = 500
        line_item.update_attributes(:quantity => 4)
        order1.compute_image_total.to_i.should == 4000
      end
    end

    context "without line items" do
      it "should return result" do
        empty_order.compute_image_total.should be_zero
      end
    end
  end

  describe "#compute_totals" do
    context "with line items" do
      it "should return result" do
        line_item = order.line_items.first
        line_item.price = 500
        line_item.update_attributes(:quantity => 4)
        order.compute_totals
        order.price_total.to_i.should == 4000
        order.order_total.to_i.should == 4000
      end
    end

    context "without line items" do
      it "should return result" do
        empty_order.compute_totals
        empty_order.price_total.should be_zero
        empty_order.order_total.to_i.should be_zero
      end
    end
  end

  describe "#completed?" do
    context "with completed status" do
      it "should return true" do
        empty_order.update_attribute(:status, "completed")
        empty_order.completed?.should be_true
      end
    end

    context "with not completed status" do
      it "should return false" do
        empty_order.completed?.should be_false
      end
    end
  end

  describe "before create callback init_transaction_date" do
    it "should assign transaction date" do
      order1 = create(:order, :transaction_date => "")
      order1.transaction_date.should_not be_blank
    end
  end

  describe "#ship_to_address" do
    context "with shipping address" do
      it "should return full address" do
        empty_order.shipping_address.update_attributes(:state => "abc", :street_address => "Street1", :zip => "111111")
        empty_order.ship_to_address.should == "Street1, City of Joy, abc, 111111, usa"
      end
    end

    context "with user's shipping address" do
      it "should return full address" do
        shipping_address = create(:shipping_address, :state => "abc", :street_address => "Street1", :zip => "111111")
        user1 = create(:user, :shipping_address_id => shipping_address.id, :billing_address_id => nil)
        new_order = create(:order, :user_id => user1.id, :shipping_address_id => nil)
        new_order.ship_to_address.should == "Street1, City of Joy, abc, 111111, usa"
      end
    end

    context "with user's billing address" do
      it "should return full address" do
        billing_address = create(:billing_address, :state => "abc", :street_address => "Street1", :zip => "111111")
        user1 = create(:user, :billing_address_id => billing_address.id, :shipping_address_id => nil)
        new_order = create(:order, :user_id => user1.id, :shipping_address_id => nil)
        new_order.ship_to_address.should == "Street1, City of Joy, abc, 111111, usa"
      end
    end
  end

end
