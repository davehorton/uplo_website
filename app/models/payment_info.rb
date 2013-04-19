class PaymentInfo

  def self.create_customer_profile(user)
    return user.an_customer_profile_id if user.an_customer_profile_id.present?

    response = GATEWAY.create_customer_profile({
      profile: {
        email: user.email,
        description: "#{user.first_name} #{user.last_name}"
      }
    })

    if !response.success?
      description = "Problem creating billing profile. #{response.try(:message)}"
      raise description
    end

    user.update_attribute(:an_customer_profile_id, response.params['customer_profile_id'])
    user.an_customer_profile_id
  end

  def self.create_payment_profile(user, credit_card)
    PaymentInfo.create_customer_profile(user)

    if user.an_customer_payment_profile_id?
      GATEWAY.delete_customer_payment_profile(
        customer_profile_id: user.an_customer_profile_id,
        customer_payment_profile_id: user.an_customer_payment_profile_id
      )
    end

    payment_profile = {
      bill_to: user.billing_address.cc_address_attributes,
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
      raise description
    end

    customer_payment_profile_id = response.params['customer_payment_profile_id']
    user.an_customer_payment_profile_id = customer_payment_profile_id
    user.save!

    response = GATEWAY.validate_customer_payment_profile(
                 customer_profile_id: user.an_customer_profile_id,
                 customer_payment_profile_id: user.an_customer_payment_profile_id,
                 validation_mode: (GATEWAY.test? ? :test : :live)
               )

    if !response.success?
      description = "Problem validating payment profile. #{response.try(:message)}"
      raise description
    end
  end
end
