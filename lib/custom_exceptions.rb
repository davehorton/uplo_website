module UploException
  class InvalidCreditCard < StandardError
    def initialize(msg = "Credit card information is invalid!")
      super(msg)
    end
  end

  class PaymentProcessError < StandardError
    def initialize(msg = "Problem with your order!")
      super(msg)
    end
  end

  class PaymentProfileError < StandardError; end
end
