class CreditCard < ActiveMerchant::Billing::CreditCard

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
    CreditCard.new(
                   first_name: first_name,
                   last_name: last_name,
                   month: options['expiration(2i)'],
                   year: options['expiration(1i)'],
                   number: options['card_number'],
                   type: options['card_type'],
                   verification_value:  options['cvv']
                   )
  end

end
