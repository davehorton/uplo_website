require 'spec_helper'

describe CreditCard do

  it "should check .brands" do
    CreditCard.brands.should_not be_blank
    CreditCard.brands.is_a?(Array).should be_true
  end

  context ".build_card_from_param" do
    let(:options) { Hash.new }

    it "handles two word names correctly" do
      options['name_on_card'] = 'John Smith'
      options['expiration'] = '1/2015'

      card = klass.build_card_from_param(options)
      card.first_name.should == 'John'
      card.last_name.should == 'Smith'
    end

    it "handles three word names correctly" do
      options['name_on_card'] = 'John J Smith'
      options['expiration'] = '1/2015'

      card = klass.build_card_from_param(options)
      card.first_name.should == 'John'
      card.last_name.should == 'Smith'
    end

    it "handles Rails date format correctly" do
      options['name_on_card'] = 'John Smith'
      options['expiration(2i)'] = '1'
      options['expiration(1i)'] = '2015'

      card = klass.build_card_from_param(options)
      card.month.should == 1
      card.year.should == 2015
    end

    it "handles date with month/year correctly" do
      options['name_on_card'] = 'John Smith'
      options['expiration'] = '1/2015'

      card = klass.build_card_from_param(options)
      card.month.should == 1
      card.year.should == 2015
    end

    it "returns an instance of ActiveMerchant::Billing::CreditCard" do
      options['name_on_card'] = 'John Smith'
      options['expiration'] = '1/2015'

      klass.build_card_from_param(options).should be_a(ActiveMerchant::Billing::CreditCard)
    end
  end

end
