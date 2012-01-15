require 'ostruct'

class Payment
  attr_accessor :amount, :currency, :user, :invoice, :item_number
  
  def self.create_paypal_test
    payment = Payment.new
    
    user_info = {
      :first_name => "Man", 
      :last_name => "Vuong", 
      :email => "man.vu_1326646895_per@techpropulsionlabs.com", 
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
  
  def self.create_authorizenet_test
  
  end
end
