require 'ostruct'
require 'active_merchant'

class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  include CartsHelper

  skip_before_filter :authenticate_user!, only: [:paypal_notify]

  def index
    @pp_payment = Payment.create_paypal_test
    @an_payment = Payment.create_authorizenet_test
  end

  # We're not currently using PayPal, but left this in here as reference
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
    redirect_to orders_path and return false if request.get?

    case params[:type]
    when "pp" # Not being used today
      total_as_cents, setup_purchase_params = get_setup_purchase_params(request)
      setup_response = pp_gateway.setup_purchase(total_as_cents, setup_purchase_params)
      redirect_to pp_gateway.redirect_url_for(setup_response.token) and return

    when "an"
      @order = Order.find(params[:order_id])
      order_info = params[:order].clone
      user_info = order_info.delete(:user)

      if params[:use_stored_cc].to_i == 0
        @credit_card = CreditCard.build_card_from_param(user_info)
        user_info[:card_number] = @credit_card.display_number
      else
        user_info = {}
      end

      if params[:ship_to_billing].present?
        order_info[:shipping_address_attributes] = order_info[:billing_address_attributes]
      end
      @order.update_attributes!(order_info)
      @order.compute_totals

      user_info[:billing_address_attributes]  = order_info[:billing_address_attributes]
      user_info[:shipping_address_attributes] = order_info[:shipping_address_attributes]

      current_user.update_profile(user_info)
      response = Payment.process_purchase(current_user, @order, @credit_card)

      if response.try(:success?)
        finalize_cart
        flash[:success] = "Congratulations! Your order is being processed."
        redirect_to order_path(@order) and return
      else
        raise UploException::PaymentProcessError
      end
    end
  rescue UploException::PaymentProcessError,
         UploException::InvalidCreditCard,
         UploException::PaymentProfileError,
         ActiveRecord::RecordInvalid => ex

    flash[:error] = ex.message
    @order.set_addresses(current_user)
    ExternalLogger.new.log_error(ex, ex.message, params) #if ex.is_a?(UploException::PaymentProfileError)
    render :template => "orders/index", :params => params
  end

  def checkout_result
    @transaction_id = params[:trans_id]
  end

  def pp_gateway
    @pp_gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(
      :login => PAYPAL_CONFIG[:api_username],
      :password => PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature]
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
      #:subtotal => Converter.decimal_to_cents(subtotal),
      #:shipping => Converter.decimal_to_cents(shipping),
      :amount => image_price,
      :handling => 0,
      :tax => 0,
      #:currency => pp_payment.currency,
      :allow_note => true,
      :invoice => order.id,
      :items => [{
        :name => "Test Image",
        :quantity => 1,
        :amount => Converter.decimal_to_cents(image_price)
      }]
    }
  end

  def auth_order
    @order_id = params[:order_id]
  end

  protected
    def finalize_cart
      if find_cart
        @order = @cart.order
        @order.finalize_transaction
      end
    end
end
