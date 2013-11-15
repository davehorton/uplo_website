require 'spec_helper'

describe Sales do
  let(:image) { create(:image) }
  let(:order) { create(:order) }

  describe "creating" do
    it "should use the image" do
      sale = Sales.new(image)
      sale.image.should == image
    end
  end

  describe "#raw_image_purchased" do
    it "should paginate" do
      sale = Sales.new(image)
      new_order = create(:completed_order, :transaction_date => "03-04-2012")
      line_items = create_list(:line_item, 20, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
      sale.raw_image_purchased({ :page => 1, :per_page => 10 }).should == line_items.last(10).reverse
    end
  end

  describe "#image_purchased_info" do
    it "should paginate" do
      sale = Sales.new(image)
      new_order = create(:completed_order, :transaction_date => "03-04-2012")
      line_items = create_list(:line_item, 20, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
      sale.image_purchased_info({ :page => 1, :per_page => 10 }).should be_a(Hash)
    end
  end

  describe "#total_image_sales" do
    context "without month" do
      it "should calculate total" do
        sale = Sales.new(image)
        new_order = create(:completed_order)

        # update line item manually to check the calculation
        2.times do
          line_item = create(:line_item, :image => image, :order => new_order)
          line_item.update_column(:price, 50.0)
          line_item.update_column(:commission_percent, 35.0)
          line_item.price.should == 50.0
          line_item.commission_percent.should == 35.0
        end

        sale.total_image_sales.should == 140.0 # 70.0 * 2, for each 50 * 4 * (35.0/100)
      end
    end

    context "with month" do
      it "should calculate total" do
        old_order = create(:completed_order, :transaction_date => 32.days.ago)
        create(:line_item, :image => image, :order => old_order, :created_at => 32.days.ago)

        # update line item manually to check the calculation
        new_order = create(:completed_order)
        line_item = create(:line_item, :image => image, :order => new_order)
        line_item.update_column(:price, 50.0)
        line_item.update_column(:commission_percent, 35.0)
        line_item.price.should == 50.0
        line_item.commission_percent.should == 35.0

        sale = Sales.new(image)
        sale.total_image_sales(Date::ABBR_MONTHNAMES[Date.today.month]).to_f.should == 70.0 # 50 * 4 * (35.0/100)
        sale.total_image_sales.should == 2070.00
      end
    end

    context "with line items having no commission percent" do
      it "should calculate correct total" do
        # gallery must be private
        image.gallery.update_attributes!(permission: "private", has_commission: false)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image => image, :order => new_order)
        sale = Sales.new(image)
        sale.total_image_sales.should be_zero
      end
    end
  end

  describe "image_monthly_sales_over_year" do
    context "without options" do
      it "should calculate result" do
        sale = Sales.new(image)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        sale.image_monthly_sales_over_year("01-04-2013").should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=> 0}]
      end
    end

    context "with options having report by quantity" do
      it "should calculate result" do
        sale = Sales.new(image)
        new_order = create(:completed_order, :transaction_date => "10-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 6)
        sale.image_monthly_sales_over_year("01-04-2013", { :report_by => "quantity"}).should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=> 6}]
      end
    end

    context "with options having report by price" do
      it "should calculate result" do
        sale = Sales.new(image)
        new_order = create(:completed_order, :transaction_date => "10-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 5)
        sale.image_monthly_sales_over_year("01-04-2013", { :report_by => "price"}).should == [{:month=>"Apr", :sales=>0}, {:month=>"May", :sales=>0}, {:month=>"Jun", :sales=>0}, {:month=>"Jul", :sales=>0}, {:month=>"Aug", :sales=>0}, {:month=>"Sep", :sales=>0}, {:month=>"Oct", :sales=>0}, {:month=>"Nov", :sales=>0}, {:month=>"Dec", :sales=>0}, {:month=>"Jan", :sales=>0}, {:month=>"Feb", :sales=>0}, {:month=>"Mar", :sales=>0}, {:month=>"Apr", :sales=>2500.0}]
      end
    end
  end

  describe "#sold_image_quantity" do
    context "without month" do
      it "should calculate total quantity" do
        sale = Sales.new(image)
        new_order = create(:completed_order)
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        sale.sold_image_quantity.should == 4
      end
    end

    context "with month" do
      it "should calculate total", :flickering do
        sale = Sales.new(image)
        order.update_attributes(:status => "completed", :transaction_date => "01-01-2013")
        new_order = create(:completed_order, :transaction_date => "05-04-2013")
        line_item = create(:line_item, :image_id => image.id, :order_id => new_order.id, :quantity => 4)
        sale.total_image_sales("April")
        sale.sold_image_quantity.should == 4
      end
    end
  end

end
