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
      :country => "USA", 
      :phone => "5120070070" 
    }
    payment.user = OpenStruct.new(user_info)
    payment.amount = 0.01
    payment.currency = "USD"
    #a random invoice number for test
    payment.invoice = Integer rand(1000)
    payment.item_number = "123"
    
    return payment
  end
  
  def self.create_authorizenet_test(card_number, expiration)
    address = AuthorizeNet::Address.new({
      :first_name => "Man",
      :last_name => "Vuong",
      :company => "TPL comp.",
      :street_address => "64 a4",
      :city => "Austin", 
      :state => "TX",
      :zip => "78759", 
      :country => "USA", 
      :phone => "5120070070", 
#      :fax => "5120070070",
      :customer_address_id => "address"
    })

    shipping_address = AuthorizeNet::ShippingAddress.new({
      :first_name => "Man",
      :last_name => "Vuong",
      :company => "TPL comp.",
      :street_address => "64 a4",
      :city => "Austin", 
      :state => "TX",
      :zip => "78759", 
      :country => "USA", 
      :phone => "5120070070" ,
#      :fax => "5120070070",
      :customer_address_id => "address"
    })
    
    credit_card = AuthorizeNet::CreditCard.new(card_number, expiration)    
    transaction = AuthorizeNet::AIM::Transaction.new(AN_CARD_NOT_PRESENT_LOGIN, AN_CARD_NOT_PRESENT_TRANS_KEY, :gateway => :sandbox, :transaction_type => :auth_and_capture, :verify_ssl => false)
    transaction.set_address(address)
    transaction.set_shipping_address(shipping_address)
    return {:transaction => transaction, :credit_card => credit_card}
  end
end
