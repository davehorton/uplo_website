require 'spec_helper'

describe LineItemObserver do
  around(:each) do |example|
    LineItem.observers.enable  :line_item_observer
    example.run
    LineItem.observers.disable :line_item_observer
  end

  describe "after_save" do
    it "calls update order", :flickering do
      order = create(:order_with_line_items)
      line_item = order.line_items.first
      line_item.price = 500
      line_item.update_attributes(:quantity => 4)
      observer = LineItemObserver.instance
      observer.after_save(line_item)
      line_item.order.order_total.to_i.should == 4000
    end
  end

  describe "after_destroy" do
    it "calls update order" do
      order = create(:order_with_line_items)
      line_item = order.line_items.first
      line_item.price = 500
      line_item.update_attributes(:quantity => 4)
      observer = LineItemObserver.instance
      observer.after_destroy(line_item)
      line_item.order.order_total.to_i.should == 4000
    end
  end

end
