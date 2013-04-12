class PaymentInfo

  def self.create_customer_profile(user)
    return user.billing_system_profile_id if user.billing_system_profile_id.present?

    response = GATEWAY.create_customer_profile({
      profile: {
        email: user.email,
        description: "#{user.first_name} #{user.last_name}",
        merchant_customer_id: "#{rand(1000)}#{Time.now.to_i}"
      }
    })

    if !response.success?
      description = "Problem creating billing profile. #{response.try(:message)}"
      raise description
    end

    user.update_attribute(:billing_system_profile_id, response.params['customer_profile_id'])
    user.billing_system_profile_id
  end

end
