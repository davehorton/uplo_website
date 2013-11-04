module UploException
  class InvalidCreditCard < StandardError
    def message
      "Credit card information is invalid!"
    end
  end

  class PaymentProcessError < StandardError
    def message
      "Problem with your order!"
    end
  end

  class PaymentProfileError < StandardError; end

end
