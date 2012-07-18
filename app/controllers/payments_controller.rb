require 'ostruct'
require 'active_merchant'

class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:paypal_notify]

  include ActiveMerchant::Billing::Integrations
  include CartsHelper

  def index
    @pp_payment = Payment.create_paypal_test
    @an_payment = Payment.create_authorizenet_test
  end

  # This is the call back for Paypal transaction.
  # You cannot test this method from localhost.
  # Deploy the app to a public server (e.g, Heroku) so that Paypal can access this method.
  def paypal_notify
    notify = Paypal::Notification.new(request.raw_post)
    Rails.logger.info "==== Paypal notify ==="
    Rails.logger.info notify.inspect

    order = Order.find_by_id(params[:invoice])
    if order
      if notify.acknowledge
        begin
          if notify.complete? and order.order_total == notify.gross.to_f
            order.finalize_transaction({
              :transaction_code => notify.transaction_id,
              :transaction_date => params[:payment_date],
              :first_name => params[:first_name],
              :last_name => params[:last_name],
              :address => params[:address_street],
              :zip_code => params[:address_zip],
              :city => params[:address_city],
              :state => params[:address_state],
              :country => params[:address_country],
              :country_code => params[:address_country_code],
              :payer_email => params[:payer_email],
              :payment_type => params[:payment_type],
              :payment_fee => params[:payment_fee],
              :currency => params[:mc_currency],
              :transaction_subject => params[:transaction_subject]
            })
            Rails.logger.info "===== Finish Paypal transaction ===="
          else
            Rails.logger.error("Failed to verify Paypal's notification, please investigate")
          end

        rescue => exc
          Rails.logger.error("===== Paypal transaction failed at order: #{order.id} =====")
          Rails.logger.error(exc)
          order.status = Order::STATUS[:failed]
          order.transaction_status = Order::TRANSACTION_STATUS[:failed]
          order.save
        end
      end
    end

    render :nothing => true
  end

  def paypal_result
    finalize_cart
  end

  def paypal_cancel
    flash[:warning] = I18n.t("order.transaction_canceled")
    redirect_to :controller => 'shopping_cart', :action => 'show'
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
        address_required_info = ['first_name', 'last_name', 'street_address', 'city', 'zip', 'state', 'phone']
        card_required_info = ['name_on_card', 'card_type', 'card_number', 'expires_on(1i)', 'expires_on(2i)', 'cvv']

        expires_on = Date.civil(params[:card]["expires_on(1i)"].to_i,
                         params[:card]["expires_on(2i)"].to_i,
                         1)
        expires_on = expires_on.strftime("%m%y")
        card_string = params[:card]["card_number"]

        order = Order.find_by_id params[:order_id]
        an_value = Payment.create_authorizenet_test(card_string, expires_on, {:shipping => params[:shipping], :address => params[:address]})
        response = an_value[:transaction].purchase(order.order_total, an_value[:credit_card])

        success = !response.nil? and response.success?
        if success
          finalize_cart
          msg = "Successfully made a purchase (authorization code: #{response.authorization_code})"
        else
          msg = 'Fail:' + response.message.to_s
        end
        redirect_to :action => :checkout_result, :msg => msg, :success => success, :trans_id => response.transaction_id
    end
  end

  def checkout_result
#    if params[:success]
#      flash[:notice] = params[:msg]
#    else
#      flash[:warn] = params[:msg]
#    end
    @transaction_id = params[:trans_id]
    render :layout => 'main'
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

  def setup_purchase_params(order)
    subtotal = 0
    shipping  = 0
    image_price = order.order_total
    return {
      :ip => request.remote_ip,
      :return_url => url_for(:only_path => false, :controller => 'payments', :action => 'paypal_result'),
      :cancel_return_url => url_for(:only_path => false, :controller => 'payments', :action => 'paypal_cancel'),
      :notify_url => url_for(:only_path => false, :controller => 'payments', :action => 'paypal_notify'),
      #:subtotal => ::Util.to_cents(subtotal),
      #:shipping => ::Util.to_cents(shipping),
      :amount => image_price,
      :handling => 0,
      :tax => 0,
      #:currency => pp_payment.currency,
      :allow_note => true,
      :invoice => order.id,
      :items => [{
        :name => "Test Image",
        :quantity => 1,
        :amount => ::Util.to_cents(image_price)
      }]
    }
  end

  def to_cents(money)
    (money*100).round
  end

  def auth_order
    @order_id = params[:order_id]
  end

  protected

  def set_current_tab
    @current_tab = "browse"
  end

  def finalize_cart
    if find_cart
      @order = @cart.order
      @order.status = Order::STATUS[:complete]
      @order.transaction_status = Order::TRANSACTION_STATUS[:complete]
      @order.save
      session[:cart] = nil
      @cart.destroy if @cart
    end
  end
end
