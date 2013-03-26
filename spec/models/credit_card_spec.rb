require 'spec_helper'

describe CreditCard do

  it "should check .brands" do
    CreditCard.brands.should == {"American Express"=>"american_express", "Master Card"=>"master", "Visa"=>"visa", "Discover"=>"discover", "JCB"=>"jcb", "Diners Club/Carte Blanche"=>"diners_club"}
  end

end
