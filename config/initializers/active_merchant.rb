require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Base.mode = :test
ActiveMerchant::Billing::PaypalGateway.default_currency = 'USD'

# PAYPAL
# Sandbox account (https://developer.paypal.com): uplo.mailer@gmail.com / uploTPL123456
PP_ACCOUNT = "uplo.m_1345779585_biz@gmail.com"
PP_API_USERNAME = "uplo.m_1345779585_biz_api1.gmail.com"
PP_API_PASSWORD = "1345779609"
PP_API_SIGN = "AaglRe.uxaLGgVcRUWEETDxysqRdATqXG5NMLob3pDjDaX7-DLbII166"

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)

PAYPAL_API_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"


# AUTHORIZE.NET
# https://test.authorize.net/: uplo-payment / uploTPL008
# https://test.authorize.net/: card-not-present / uploTPL007$
AUTHORIZENET_API = YAML.load_file(Rails.root.join("config/authorizenet.yml"))[Rails.env].symbolize_keys

ActiveMerchant::Billing::Base.mode = :test if (AUTHORIZENET_API[:testmode] == true)

::GATEWAY = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
              login:    AUTHORIZENET_API[:login],
              password: AUTHORIZENET_API[:password],
              test:     AUTHORIZENET_API[:testmode]
)
