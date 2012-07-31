class SalesController < ApplicationController
  include ::SharedMethods
  before_filter :authenticate_user!
  layout 'main'

  def index
    return redirect_to :action => :year_sales
  end

  def image_sale_details
    @image = Image.find_by_id params[:id]
    @sales = @image.get_monthly_sales_over_year(Time.now, {:report_by => Image::SALE_REPORT_TYPE[:price]})
    @purchased_info = @image.raw_purchased_info(@filtered_params)
  end

  def year_sales
    user = current_user
    @sales = user.raw_sales(@filtered_params)
    @monthly_sales = user_monthly_sales(@sales)
    @year_sales = user_year_sales(@monthly_sales)
  end

  protected

  def set_current_tab
    @current_tab = "sales"
  end

  def user_monthly_sales(sales)
    result = []
    date = DateTime.parse Time.now.to_s
    prior_months = TimeCalculator.prior_year_period(date, {:format => '%b'})
    prior_months.each { |mon|
      total_sales = 0
      sales.each { |img|
        total_sales += img.total_sales(mon);
      }
      result << {:month => mon, :sales => total_sales}
    }
    return result
  end

  def user_year_sales(sales)
    rs = 0
    sales.each { |sale|
      rs += sale[:sales]
    }
    return rs
  end
end
