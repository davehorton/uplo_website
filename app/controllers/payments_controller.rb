require 'ostruct'
require 'active_merchant' 

class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  include ActiveMerchant::Billing::Integrations
  
  def index
    @pp_payment = Payment.create_paypal_test
    @an_payment = Payment.create_authorizenet_test
  end
  
  def paypal_notify
    notify = Paypal::Notification.new(request.raw_post)
    puts "==== Paypal notify ==="
    puts notify.inspect
    if notify.acknowledge
      puts "=== Transaction ID is #{notify.transaction_id}"
      puts "=== Notify is #{notify}"
      puts "=== Notify status is #{notify.status}"
    end
    render :nothing => true
  end
  
  def paypal_result
    if find_cart
      @order = @cart.order
      @order.status = Order::STATUS[:complete]
      @order.transaction_status = Order::TRANSACTION_STATUS[:complete]
      @order.save
      session[:cart] = nil
      @cart.destroy if @cart
    end
  end
  
  def paypal_cancel
  
  end
  
  def checkout
    case params[:type]
      when "pp"
        total_as_cents, setup_purchase_params = get_setup_purchase_params(request)
        setup_response = pp_gateway.setup_purchase(total_as_cents, setup_purchase_params)
        if !setup_response.success?
          puts "===== setup_response ==="
          puts setup_response.params.inspect
        end
        redirect_to pp_gateway.redirect_url_for(setup_response.token)
      when "an"
        an_payment = Payment.create_paypal_test
        transaction = AuthorizeNet::AIM::Transaction.new(AN_LOGIN_ID, AN_TRANS_KEY,
          :gateway => :card_present_sandbox)
        response = transaction.purchase(an_payment.amount, an_credit_card)

        if response.success?
          flash[:notice] = "Successfully made a purchase (authorization code: #{response.authorization_code})"
        else
          flash[:warn] = 'Fail:' + response.message.to_s
        end
        
        redirect_to :action => :index
    end
  end
  
  def pp_gateway
    @pp_gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(
      :login => PP_API_USERNAME,
      :password => PP_API_PASSWORD,
      :signature => PP_API_SIGN
    )
  end

  def an_gateway
    @an_gateway ||= ActiveMerchant::Billing::AuthorizeNetGateway.new(
    :login => AN_LOGIN_ID,
    :password => AN_TRANS_KEY, 
    :test => true)
  end
  
  def an_credit_card
    @an_credit_card ||= AuthorizeNet::CreditCard.new(nil, nil, 
    :track_1 => '%B4111111111111111^DOE/JOHN^1803101000000000020000831000000?')
  end
  
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :number     => '4007000000027',
      :month      => '8',
      :year       => '2020',
      :first_name => 'Uplo',
      :last_name  => 'Payment',
      :verification_value  => '123',
      :type => "visa"
    )
  end
  
  def get_setup_purchase_params(request)
    pp_payment = Payment.create_paypal_test
    total = pp_payment.amount
    subtotal = 0
    shipping  = 0
    image_price = pp_payment.amount
    return to_cents(total), {
      :ip => request.remote_ip,
      :return_url => url_for(:only_path => false, :controller => 'payments', :action => 'paypal_result'),
      :cancel_return_url => url_for(:only_path => false, :controller => 'payments', :action => 'paypal_cancel'),
      :subtotal => to_cents(subtotal),
      :shipping => to_cents(shipping),
      :amount => pp_payment.amount,
      :handling => 0,
      :tax => 0,
      :currency => pp_payment.currency,
      :allow_note => true,
      :invoice => pp_payment.invoice, 
      :items => [{
        :name => "Test Image",
        :number => "123456",
        :quantity => 1,
        :amount => to_cents(image_price)
      }]
    }
  end
  
  def to_cents(money)
    (money*100).round
  end
  
  protected
  
  def set_current_tab
    @current_tab = "browse"
  end
  
  private
    def find_cart
      @cart = Cart.find_by_id(session[:cart])
      if @cart.nil? or @cart.empty?
        flash[:warning] = "Sorry, your shopping cart is empty. (Did you already submit your order? Check your email for receipts.)"
        redirect_to :controller => 'shopping_cart', :action => 'show'
        false
      else
        true
      end
    end
end
