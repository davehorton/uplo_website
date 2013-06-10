require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

PAYPAL_CONFIG = YAML.load_file(Rails.root.join("config/paypal.yml"))[Rails.env].symbolize_keys
AUTHORIZENET_API = YAML.load_file(Rails.root.join("config/authorizenet.yml"))[Rails.env].symbolize_keys

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
ActiveMerchant::Billing::PaypalGateway.default_currency = 'USD'
ActiveMerchant::Billing::Base.mode = :test if (AUTHORIZENET_API[:testmode] == true)

::GATEWAY = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
              login:    AUTHORIZENET_API[:login],
              password: AUTHORIZENET_API[:password],
              test:     AUTHORIZENET_API[:testmode]
)
