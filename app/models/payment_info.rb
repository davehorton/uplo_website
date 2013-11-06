class PaymentInfo

  def self.create_customer_profile(user)
    return user.an_customer_profile_id if user.an_customer_profile_id.present?

    response = GATEWAY.create_customer_profile({
      profile: {
        email: user.email,
        description: "#{user.first_name} #{user.last_name}",
        merchant_customer_id: user.merchant_customer_id
      }
    })

    if response.success?
      customer_profile_id = response.params['customer_profile_id']
      user.an_customer_profile_id = customer_profile_id
      user.save!
      user.an_customer_profile_id
    else
      description = "Problem creating billing profile. #{response.try(:message)}"
      raise UploException::PaymentProfileError.new(description)
    end
  end

  def self.create_payment_profile(user, credit_card)
    PaymentInfo.create_customer_profile(user)

    if user.an_customer_payment_profile_id?
      GATEWAY.delete_customer_payment_profile(
        customer_profile_id: user.an_customer_profile_id,
        customer_payment_profile_id: user.an_customer_payment_profile_id
      )
      user.update_column(:an_customer_payment_profile_id, nil)
    end

    billing_address = user.billing_address.try(:cc_address_attributes) || {}
    billing_address.merge!(first_name: credit_card.first_name, last_name: credit_card.last_name)

    payment_profile = {
      bill_to: billing_address,
      payment: {
        credit_card: credit_card
      }
    }

    options = {
      customer_profile_id: user.an_customer_profile_id,
      payment_profile: payment_profile
    }

    response = GATEWAY.create_customer_payment_profile(options)
    if !response.success?
      description = "Problem creating payment profile. #{response.try(:message)}"
      raise UploException::PaymentProfileError.new(description)
    end

    customer_payment_profile_id = response.params['customer_payment_profile_id']
    user.an_customer_payment_profile_id = customer_payment_profile_id
    user.save!
  end

  def self.update_billing_address(user)
    response = GATEWAY.get_customer_payment_profile(
                 customer_profile_id: user.an_customer_profile_id,
                 customer_payment_profile_id: user.an_customer_payment_profile_id
               )

    payment_profile = response.params['payment_profile']
    bill_to = payment_profile['bill_to'].to_options
    billing_address = user.billing_address.try(:cc_address_attributes).try(:to_options) || {}
    billing_address.merge!(first_name: bill_to[:first_name], last_name: bill_to[:last_name])

    payment_profile = {
      customer_payment_profile_id: user.an_customer_payment_profile_id,
      bill_to: billing_address,
      payment: {
        credit_card: CreditCard.new(
          number: payment_profile['payment']['credit_card']['card_number']
        )
      }
    }

    options = {
      customer_profile_id: user.an_customer_profile_id,
      payment_profile: payment_profile
    }

    response = GATEWAY.update_customer_payment_profile(options)

    if !response.success?
      description = "Problem updating billing address. #{response.try(:message)}"
      raise UploException::PaymentProfileError.new(description)
    end
  end
end
