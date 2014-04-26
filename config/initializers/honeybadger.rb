Honeybadger.configure do |config|
  config.api_key = 'e1521a6d'
  config.params_filters << "card_type"
  config.params_filters << "name_on_card"
  config.params_filters << "cvv"
  config.params_filters << "expiration"
  config.params_filters << "4750556078184269"
end
