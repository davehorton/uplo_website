require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing:: Base.mode = :test
PAYPAL_ACCOUNT = "man.vu_1326647847_biz@techpropulsionlabs.com"

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
