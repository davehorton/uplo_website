require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Base.mode = :test

# PAYPAL
# Sandbox account (https://developer.paypal.com): uplo.mailer@gmail.com / uploTPL123456
PP_ACCOUNT = "uplo.m_1326686532_biz@gmail.com"
PP_BUYER_ACCOUNT = "uplo.m_1326686491_per@gmail.com"
PP_API_USERNAME = "uplo.m_1326686532_biz_api1.gmail.com"
PP_API_PASSWORD = "1326686570"
PP_API_SIGN = "Anc0D5BOPhFy6OAh3om9ZbTOUhc.AHydVYiJ6OWgmn--YrOOe.-2ukI1"

# AUTHORIZE.NET
# https://test.authorize.net/: uplo-payment / uploTPL007
AN_LOGIN_ID = "5rEw33WW37dT"
AN_TRANS_KEY = "4J3qwE54h8Z4Lvcd"
  
ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)

PAYPAL_API_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
