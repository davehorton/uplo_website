require 'spec_helper'

describe ShippingPrice do

  it "has a default scope" do
    product1 = create(:product, :size => create(:size))
    product2 = create(:product, :size => create(:square_size))
    shipping_price1 = create(:shipping_price, :product_id => product1.id)
    shipping_price2 = create(:shipping_price, :product_id => product2.id)
    klass.all.should == [shipping_price2, shipping_price1]
  end

end
