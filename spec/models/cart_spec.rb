require 'spec_helper'

describe Cart do

  it { should belong_to(:user) }
  it { should belong_to(:order) }
  it { should have_many(:line_items).through(:order) }

  describe "#clear" do
    it "should destroy all associated line items" do
      order = create(:order_with_line_items)
      cart = create(:cart, :order => order)
      cart.line_items.count.should == 2
      cart.clear
      cart.line_items.should == []
    end
  end

  describe "#assign_empty_order!" do
    it "should create a new order" do
      cart = create(:cart, :order => nil)
      cart.assign_empty_order!
      cart.order.should_not be_nil
      cart.order.status.should == "shopping"
    end
  end

end
