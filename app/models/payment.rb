require 'ostruct'

class Payment
  attr_accessor :amount, :currency, :user, :invoice, :item_number

  def self.create_paypal_test
    payment = Payment.new

    user_info = {
      :first_name => "Man",
      :last_name => "Vuong",
      :email => PP_BUYER_ACCOUNT,
      :address1 => "awesome ln",
      :city => "Austin",
      :state => "TX",
      :zip => "78759",
      :country => "USA"
    }
    payment.user = OpenStruct.new(user_info)
    payment.amount = 0.01
    payment.currency = "USD"
    #a random invoice number for test
    payment.invoice = Integer rand(1000)
    payment.item_number = "123"

    return payment
  end

  def self.transfer_balance_via_paypal(amount, receiver)
    ActiveMerchant::Billing::PaypalGateway.default_currency = 'USD'
    gateway = ActiveMerchant::Billing::PaypalGateway.new({
      :login => PP_API_USERNAME,
      :password => PP_API_PASSWORD,
      :signature => PP_API_SIGN
    })

    gateway.transfer(Converter.decimal_to_cents(amount), receiver, :subject => 'Payment from UPLO', :note => "UPLO has transfered $#{amount} for your request payout.")
  end

  def self.process_purchase(user, order, credit_card = nil)
    raise "Need credit card to complete purchase" unless (user.an_customer_payment_profile_id || credit_card)
    PaymentInfo.create_payment_profile(user, credit_card) if credit_card

    transaction = {
      transaction: {
        type: :auth_capture,
        amount: order.order_total,
        customer_profile_id: user.an_customer_profile_id,
        customer_payment_profile_id: user.an_customer_payment_profile_id
      }
    }

    GATEWAY.create_customer_profile_transaction(transaction)
  end

end
