require 'spec_helper'

describe Order do
  it { should belong_to(:shipping_address).class_name(:address) }
  it { should belong_to(:billing_address).class_name(:address) }
end
