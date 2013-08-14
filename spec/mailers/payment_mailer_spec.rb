require "spec_helper"

describe PaymentMailer do
  let(:order) { create(:order, :status => "shopping", :tax => 10.0) }
  let(:cart) { create(:cart, :order_id => order.id) }
  let(:mail) { PaymentMailer.inform_new_order(order.id) }

  before { ActionMailer::Base.deliveries = [] }

  it "should send inform order email after an order is completed" do
    order.finalize_transaction
    ActionMailer::Base.deliveries.should_not be_empty
  end

  scenario "email details" do
    mail.subject.should eq("Password Reset")
    mail.to.should eq(["patrick@uplo.com", "uplo@digital2media.com"])
    mail.from.should eq(["support@uplo.com"])
  end

  scenrio "renders the body" do
    mail.body.encoded.should have_selector("p", :text => "#{order.user.username} (#{order.user.fullname}, #{mail_to order.user.email}) purchased a photo on Uplo.com.")
  end


end

