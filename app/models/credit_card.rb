class CreditCard < ActiveMerchant::Billing::CreditCard

  include ActiveAttr::Model

  attribute :address
  attribute :city
  attribute :state
  attribute :zip

  validates_presence_of :address, :city, :state, :zip

  ACCEPTED_CREDIT_CARDS = [
                           ['American Express', 'american_express'],
                           ['Discover', 'discover'],
                           ['MasterCard', 'master'],
                           ['Visa', 'visa'],
                           ['JCB', 'jcb'],
                           ['Diners Club/Carte Blanche', 'diners_club']
                          ]

  def self.brands
    ACCEPTED_CREDIT_CARDS
  end

  def self.build_card_from_param(options)
    first_name, last_name = options['name_on_card'].split
    billing_address = options[:billing_address_attributes]

    CreditCard.new(
                   first_name: first_name,
                   last_name: last_name,
                   month: options['expiration(2i)'],
                   year: options['expiration(1i)'],
                   number: options['card_number'],
                   brand: options['card_type'],
                   verification_value:  options['cvv'],
                   address: [billing_address[:street_address], billing_address[:optional_address]].join(','),
                   city: billing_address[:city],
                   state: billing_address[:state],
                   zip: billing_address[:zip]
                   )
  end


  def billing_address
    {
      address: self.address,
      city: self.city,
      state: self.state,
      zip: self.zip,
    }
  end

end
