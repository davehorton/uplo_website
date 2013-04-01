class SalesController < ApplicationController
  def index
    return redirect_to :action => :year_sales
  end

  def image_sale_details
    @image = Image.find_by_id params[:id]
    @sales = ImageDecorator.decorate_collection(@image.get_monthly_sales_over_year(Time.now, {:report_by => Image::SALE_REPORT_TYPE[:price]}))
    @purchased_info = @image.raw_purchased_info(filtered_params)
  end

  def year_sales
    @sales = current_user.raw_sales.paginate_and_sort(filtered_params)
    @monthly_sales = current_user.monthly_sales(Time.now)
    @year_sales = total_sales(@monthly_sales)
  end

  def withdraw
    if (current_user.withdraw_paypal(current_user.owned_amount))
      flash[:notice] = "Withdraw successfully"
    else
      error = '<ul>'
      current_user.errors.full_messages.each do |message|
        error << "<li>#{message}</li>"
      end
      error << '</ul>'
      flash[:errors] = error.html_safe
    end

    redirect_to :controller => 'sales', :action => 'year_sales'
  end

  protected

    def total_sales(sales)
      rs = 0
      sales.each { |sale| rs += sale[:sales] }
      return rs
    end
end
