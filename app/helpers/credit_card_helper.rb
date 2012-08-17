module CreditCardHelper

  def check_cc_number(number, card_type)
    return (number_valid?(number) && number_matches_type(number, card_type))
  end

  def number_valid?(number)
    odd = true
    number.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
      d *= 2 if odd = !odd
      d > 9 ? d - 9 : d
    }.sum % 10 == 0
  end

  def ccTypeCheck(ccNumber)
    ccNumber = ccNumber.gsub(/\D/, '')
    case ccNumber
      when /^3[47]\d{13}$/ then return "USA_express"
      when /^4\d{12}(\d{3})?$/ then return "visa"
      when /^5\d{15}|36\d{14}$/ then return "master_card"
      when /^6011\d{12}|650\d{13}$/ then return "discover"
      when /^3(0[0-5]|8[0-1])\d{11}$/ then return "dinners_club"
      when /^(39\d{12})|(389\d{11})$/ then return "CB"
      when /^3\d{15}|1800\d{11}|2131\d{11}$/ then return "jcb"
      else return "NA"
    end
  end

  def number_matches_type?(number,card_type)
    return card_type == ccTypeCheck(number)
  end

  def card_types
    {"American Express" => "USA_express",
      "Discover" => "discover", 
      "Visa" => "visa", 
      "JCB" => "jcb", 
      "Diners Club/ Carte Blanche" => "dinners_club", 
      "Master Card" => "master_card"
    }
  end

end