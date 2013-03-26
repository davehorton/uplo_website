require 'spec_helper'

describe LineItem do
  it { should belong_to(:image) }
  it { should belong_to(:product) }
  it { should belong_to(:order) }

  it { should validate_numericality_of(:quantity) }

  describe "#total_price" do
    it "should be calculated" do
      line_item =  create(:line_item, :price => 500, :quantity => 5)
      line_item.total_price.should == 2500
    end
  end

  describe "#calculate_totals" do
    it "should return calculated result" do
      new_line_item = create(:line_item, :price => 500)
      new_line_item.calculate_totals
      new_line_item.tax.should be_zero
    end
  end
end

