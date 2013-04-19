require 'spec_helper'

describe CreditCard do

  it "should check .brands" do
    CreditCard.brands.should_not be_blank
    CreditCard.brands.is_a?(Array).should be_true
  end

end
