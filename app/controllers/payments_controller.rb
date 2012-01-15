require 'ostruct'
require 'active_merchant' 

class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  include ActiveMerchant::Billing::Integrations
  include ActiveMerchant::Billing
  
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
    end
  end
  
  def pp_gateway
    @pp_gateway ||= PaypalExpressGateway.new(
      :login => "man.vu_1326647847_biz_api1.techpropulsionlabs.com",
      :password => "1326647884",
      :signature => "A4SdiHKfPQhiL0XrZSBoi7ft4tKHA1P76IKXYaZi7xHu2Vv2VRZqNX3B"
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
end
