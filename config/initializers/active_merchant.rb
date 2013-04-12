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

# AUTHORIZE.NET
# https://test.authorize.net/: uplo-payment / uploTPL008
# https://test.authorize.net/: card-not-present / uploTPL007$
AN_LOGIN_ID = "56weNE5N8cG3"
AN_TRANS_KEY = "7baEgf3P875XTv6z"
AN_CARD_NOT_PRESENT_LOGIN = "92RQRn7r9R"
AN_CARD_NOT_PRESENT_TRANS_KEY = "6gEMD4F6g3rx3U27"
AN_HASH_VALUE = "a3317f627b92eef9b6126b7a50e196c3"

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)

PAYPAL_API_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"


::GATEWAY = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
  login:    AN_LOGIN_ID,
  password: AN_TRANS_KEY,
  test:     true
)
