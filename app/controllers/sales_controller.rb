class SalesController < ApplicationController
  def index
    return redirect_to :action => :year_sales
  end

  def image_sale_details
    @image = current_user.images.find(params[:id])
    @sale = @image.sale
    @sales = ImageDecorator.decorate_collection(@sale.image_monthly_sales_over_year(Time.now, {:report_by => Image::SALE_REPORT_TYPE[:price]}))
    @purchased_info = @sale.raw_image_purchased(filtered_params)
  end

  def year_sales
    @sold_images = current_user.sold_images.paginate_and_sort(filtered_params)
    @monthly_sales = current_user.monthly_sales
    @total_sale = @monthly_sales.sum { |sale| sale[:sales] }
  end

  def withdraw
    if current_user.withdraw_paypal(current_user.owned_amount)
      flash[:notice] = "Withdraw successful"
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
end
