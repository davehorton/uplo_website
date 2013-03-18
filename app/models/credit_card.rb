class CreditCard
  include ActiveMerchant::Billing::CreditCardMethods

  def self.brands
    {
      "American Express" => "american_express",
      "Master Card"      => "master"
      "Visa"             => "visa",
      "Discover"         => "discover",
      "JCB"              => "jcb",
      "Diners Club/Carte Blanche" => "diners_club",
    }
  end
end
