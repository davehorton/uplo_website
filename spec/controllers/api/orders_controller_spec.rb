require 'spec_helper'

describe Api::OrdersController do

  login_user

  let!(:square_size) { create(:size, width: 8, height: 8) }
  let!(:rectangular_size) { create(:size, width: 8, height: 10) }
  let!(:square_product) { create(:product, size: square_size) }
  let!(:rectangular_product) { create(:product, size: rectangular_size, tier1_price: 600) }
  let!(:product_option) { create(:product_option, product: rectangular_product, description: "testing") }
  let(:image) { create(:real_image) }
  let(:cart) { create(:cart, user_id: subject.current_user.id) }

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  context "#add_item" do

    context "when item hash is blank" do
      it "should show error message" do
        post :add_item, {:item => { }}
        response.body.should == "{\"msg\":\"Not found\"}"
      end
    end

    context "when item hash is not blank" do

      it "should increase the quantity of line item when matching line item present" do
        line_item = create(:line_item, order: cart.order, image: image, product_id: rectangular_product.id, product_option_id: product_option.id)
        post :add_item, {"item"=>{"product_option_id"=>"#{product_option.id}", "image_id"=>"#{image.id}", "product_id"=>"#{rectangular_product.id}", "quantity"=>"5"}}
        response.should be_success
        response.body.should == LineItemSerializer.new(line_item.reload, scope: subject.current_user).to_json
        line_item.quantity.should == 9
      end

      it "should add a new line item when matching line item not present" do
        post :add_item, {"item"=>{"product_option_id"=>"#{product_option.id}", "image_id"=>"#{image.id}", "product_id"=>"#{rectangular_product.id}", "quantity"=>"4"}}
        response.body.should == LineItemSerializer.new(LineItem.last, scope: subject.current_user).to_json
        LineItem.last.quantity.should == 4
        LineItem.last.image.should  == image
        LineItem.last.price.to_f.should == 600.0
      end
    end
  end

  context "#update_item" do

    context "when item hash is blank" do
      it "should show error message" do
        put :update_item, {:item => { }}
        response.body.should == "{\"msg\":\"Not found\"}"
      end
    end

    context "when item hash is not blank" do

      it "should update the line item" do
        line_item = create(:line_item, order: cart.order, image: image)
        put :update_item, {"id"=>"#{line_item.id}", "item"=>{"image_id"=>"#{image.id}", "product_id"=>"#{rectangular_product.id}", "quantity"=>"10"}}
        response.should be_success
        response.body.should == LineItemSerializer.new(line_item.reload, scope: subject.current_user).to_json
        line_item.quantity.should == 10
        line_item.price.to_f.should == 600.0
        line_item.product.should == rectangular_product
      end
    end

  end

  context "#delete_ordered_item" do

    it "should destroy line item if not finalized" do
      line_item = create(:line_item, order: cart.order, image: image)
      delete :delete_ordered_item, id: line_item.id
      response.should be_success
      response.body.should == "{\"success\":true}"
    end
  end

  context "#create" do

    context "when order hash is correct" do

      it "should create a new order" do
        line_item = create(:line_item, order: cart.order, image: image, product: rectangular_product, product_option: product_option)
        order_hash = {"order"=>{"transaction_status"=>"completed", "billing_address_attributes"=>{"optional_address"=>"", "last_name"=>"test", "zip"=>"555555555", "state"=>"AK", "city"=>"kol", "street_address"=>"1/16", "first_name"=>"nb"}, "card_type"=>"visa", "shipping_address_attributes"=>{"street_address"=>"1/16", "state"=>"AK", "zip"=>"555555555", "optional_address"=>"", "last_name"=>"bn", "city"=>"kol", "first_name"=>"nb"}, "name_on_card"=>"nb test", "cvv"=>"123", "expiration"=>"11/2023", "card_number"=>"4111111111111111"}}
        post :create, order_hash
        response.should be_success
        response.body.should == "{\"msg\":\"Order charged\"}"
        subject.current_user.reload.cart.should be_nil
        subject.current_user.card_number.should == "XXXX-XXXX-XXXX-1111"
        subject.current_user.billing_address.zip.should == "555555555"
        subject.current_user.shipping_address.street_address.should == "1/16"
      end
    end

    context "when order hash is incorrect" do

      it "should show error message" do
        line_item = create(:line_item, order: cart.order, image: image, product: rectangular_product, product_option: product_option)
        order_hash = {"order"=>{"transaction_status"=>"completed", "billing_address_attributes"=>{"optional_address"=>"", "last_name"=>"test", "zip"=>"555555555", "state"=>"AK", "city"=>"kol", "street_address"=>"1/16", "first_name"=>"nb"}, "card_type"=>"visa", "shipping_address_attributes"=>{"street_address"=>"1/16", "state"=>"AK", "zip"=>"555555555", "optional_address"=>"", "last_name"=>"bn", "city"=>"kol", "first_name"=>"nb"}, "name_on_card"=>"nb test", "cvv"=>"123", "expiration"=>"11/2023", "card_number"=>"4111111111111001"}}
        post :create, order_hash
        response.should_not be_success
        response.body.should == "{\"msg\":\"Problem charging card for order. Credit card information is invalid!\"}"
      end
    end

  end

  context "#cart" do

    context "with order" do
      it "should show the present order in the cart" do
        cart
        get :cart
        response.should be_success
        response.body.should == OrderSerializer.new(cart.order).to_json
      end
    end

  end
end
