require 'spec_helper'

describe ProductOption do
  let(:product_option) { create(:product_option, :description => "test product") }

  it { should belong_to(:product) }

  it "has a default_scope of order id" do
    product_option
    b = create(:product_option)
    klass.all.should == [product_option, b]
  end

  describe "preview_image_name" do
    it "should return proper result" do
      product_option.preview_image_name.should == "preview_#{product_option.product.size.to_name}_#{product_option.description.parameterize}".to_sym
    end
  end

  describe "ordered_print_image_name" do
    it "should return proper result" do
      product_option.ordered_print_image_name.should == "order_#{product_option.product.size.to_name}_#{product_option.description.parameterize}".to_sym
    end
  end

end
