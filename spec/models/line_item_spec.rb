require 'spec_helper'
require 'sidekiq/testing/inline'

describe LineItem do
  before { create_sizes }
  let(:line_item) { create(:line_item, image: create(:image))}
  let(:order) { create(:order) }

  it { should belong_to(:image) }
  it { should belong_to(:product) }
  it { should belong_to(:product_option) }
  it { should belong_to(:order) }

  it { should validate_numericality_of(:quantity) }

  describe ".sold_items" do
    context "with matching orders" do
      it "should return appropriate line items" do
        line_item.order.update_attribute(:transaction_status, "completed")
        LineItem.sold_items.should == [line_item]
      end
    end

    context "without matching orders" do
      it "should return blank array" do
        LineItem.sold_items.should == []
      end
    end
  end

  describe "total_price" do
    it "should calculate total" do
      line_item.update_attributes(:tax => 10.0, :quantity => 4)
      line_item.price = 500
      line_item.total_price.should == 2000
    end
  end

  describe "#calculate_totals" do
    context "when order is in new york" do
      it "should apply regional tax" do
        order.billing_address.update_attribute(:state, "NY")
        new_line_item = create(:line_item, :order => order)
        new_line_item.tax.should == 44.375
        new_line_item.price.should == 500
      end
    end

    context "when order is not in new york" do
      it "should not apply regional tax" do
        line_item.price.should == 500
        line_item.tax.should be_zero
        line_item.commission_percent.should == 100
      end
    end

    context "when user owns image" do
      it "should subtract discount from total price" do
        product1  = create(:product, :tier4_price => 500.0, :tier4_commission => 10)
        img = create(:image, :tier_id => 4)
        new_order = create(:order, :user => img.user)
        new_line_item = create(:line_item, :product => product1, :order => new_order, :image => img)
        new_line_item.price.to_i.should == 450
      end
    end

    context "when user does not own image" do
      it "should return the exact price" do
        product1  = create(:product, :tier4_price => 500.0, :tier4_commission => 10)
        img = create(:image, :tier_id => 4)
        new_line_item = create(:line_item, :product => product1, :image => img)
        new_line_item.price.to_i.should == 500
      end
    end

  end

  describe "#dropbox_path" do
    it "should return the dropbox path" do
      line_item1 = create(:line_item, :content_file_name => 'test.jpg')
      line_item1.dropbox_path.should == "orders/#{line_item1.order.id}/#{line_item1.id}.jpg"
    end
  end

  describe "#s3_expire_time" do
    it "should return proper time" do
      line_item.s3_expire_time.should == "#{Time.zone.now.beginning_of_day.since 25.hours}"
    end
  end
end
