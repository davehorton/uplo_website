require 'spec_helper'
require 'sidekiq/testing/inline'

describe LineItem do
  before { create_sizes }
  let(:line_item) { create(:line_item, image: create(:image))}

  it { should belong_to(:image) }
  it { should belong_to(:product) }
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
    context "executing before_save calback" do
      it "should calculate result" do
        line_item.price.should == 500
        line_item.tax.should be_zero
        line_item.commission_percent.should == 100
      end
    end
  end

  describe "#set_crop_dimension" do
    it "should set crop dimension field from a hash" do
      options = {crop_x: "1445", crop_y: "312", crop_w: "888", crop_h: "888"}
      line_item.set_crop_dimension(options)
      line_item.crop_dimension.should == "888x888+1445+312"
    end
  end

  describe "#cropped_dimensions" do
    it "should return an empty array" do
      line_item.cropped_dimensions.should == []
    end

    it "should not return an empty array" do
      options = {crop_x: "1445", crop_y: "312", crop_w: "888", crop_h: "888"}
      line_item.set_crop_dimension(options)
      line_item.cropped_dimensions.should == [888, 888, 1445, 312]
    end
  end

  describe "#cropping?" do
    context "with cropping parameters" do
      it "should return true" do
        line_item.update_attributes(:crop_x => 40, :crop_y => 50, :crop_h => 40, :crop_w => 50)
        line_item.cropping?.should be_true
      end
    end

    context "without cropping parameters" do
      it "should return false" do
        line_item.cropping?.should be_false
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

