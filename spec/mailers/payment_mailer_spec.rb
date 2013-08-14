require "spec_helper"

describe PaymentMailer do
  let(:order) { create(:order, :status => "shopping", :tax => 10.0, :shipping_fee => 20.0) }
  let(:mail) { PaymentMailer.inform_new_order(order.id) }

  before { ActionMailer::Base.deliveries = [] }

  it "should send inform order email after an order is completed" do
    cart = create(:cart, :order_id => order.id)
    order.finalize_transaction
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should match email details" do
    mail.subject.should eq("New Order")
    mail.to.should eq(["patrick@uplo.com", "uplo@digital2media.com"])
    mail.from.should eq(["support@uplo.com"])
  end

  it "renders the body" do
    mail.body.encoded.should have_content("#{order.user.username} (#{order.user.fullname}")
    mail.body.encoded.should have_selector("p", :text => "Shipping Address: #{order.ship_to_address}")
    mail.body.encoded.should have_selector("h3", :text => "Order Summary")
    mail.body.encoded.should have_content("Tax: $10.0")
    mail.body.encoded.should have_content("S&H: $20.0")
    mail.body.encoded.should have_selector("p", :text => "The cropped and original photos will appear shortly in the Uplo Dropbox subfolder named #{order.dropbox_order_root_path}.")
  end

end

