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

  def self.create_authorizenet_test(card_number, expiration, addresses)
    credit_card = AuthorizeNet::CreditCard.new(card_number, expiration)
    transaction = AuthorizeNet::AIM::Transaction.new(AN_LOGIN_ID, AN_TRANS_KEY, :gateway => :production, :transaction_type => :auth_and_capture, :verify_ssl => false)

    if addresses.has_key?(:address) and !addresses[:address].blank?
      addresses[:address][:customer_address_id] = "address"
      address = AuthorizeNet::Address.new(addresses[:address])
      transaction.set_address(address)
    end

    if addresses.has_key?(:shipping) and !addresses[:shipping].blank?
      addresses[:shipping][:customer_address_id] = "address"
      shipping_address = AuthorizeNet::ShippingAddress.new(addresses[:shipping])
      transaction.set_shipping_address(shipping_address)
    end

    return {:transaction => transaction, :credit_card => credit_card}
  end

  def self.transfer_ballance_via_paypal(amount, receiver)
    ActiveMerchant::Billing::PaypalGateway.default_currency = 'USD'
    gateway = ActiveMerchant::Billing::PaypalGateway.new({
      :login => PP_API_USERNAME,
      :password => PP_API_PASSWORD,
      :signature => PP_API_SIGN
    })

    gateway.transfer(Converter.decimal_to_cents(amount), receiver, :subject => 'Payment from UPLO', :note => "UPLO has transfered $#{amount} for your request payout.")
  end
end
