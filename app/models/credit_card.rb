class CreditCard < ActiveMerchant::Billing::CreditCard

  ACCEPTED_CREDIT_CARDS = [
                           ['American Express', 'american_express'],
                           ['Discover', 'discover'],
                           ['MasterCard', 'master'],
                           ['Visa', 'visa']
                          ]

  def self.brands
    ACCEPTED_CREDIT_CARDS
  end

  def self.build_card_from_param(options)
    first_name, middle_name, last_name = options['name_on_card'].split
    if last_name.nil?
      last_name = middle_name
    end

    if options['expiration(2i)'].present? && options['expiration(1i)'].present?
      month = options['expiration(2i)']
      year  = options['expiration(1i)']
    else
      month, year = options['expiration'].split('/')
    end

    CreditCard.new(
                   first_name: first_name,
                   last_name: last_name,
                   month: month,
                   year: year,
                   number: options['card_number'],
                   brand: options['card_type'],
                   verification_value:  options['cvv'],
                   )
  end
end
