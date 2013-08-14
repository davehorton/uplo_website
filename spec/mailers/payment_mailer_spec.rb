require "spec_helper"

describe PaymentMailer do
  before { ActionMailer::Base.deliveries = [] }

  it "should send inform order email after an order is completed" do
    order = create(:order, :status => "shopping", :tax => 10.0)
    cart = create(:cart, :order_id => order.id)
    order.finalize_transaction
    ActionMailer::Base.deliveries.should_not be_empty
  end

end

