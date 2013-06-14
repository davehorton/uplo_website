class Admin::OrdersController < Admin::AdminController
  self.per_page = 20

  def index
    @orders = Order.scoped
    @orders = params[:transaction_status] ? @orders.in_status(params[:transaction_status]) : @orders.completed
    @orders = @orders.paginate_and_sort(filtered_params.merge(:sort_field => "created_at", :sort_direction => "desc" ))
  end

  def show
    @order = Order.find(params[:id])
  end

  def resend_fulfillment_email
    @order = Order.find(params[:id])
    PaymentMailer.delay.inform_new_order(@order.id)
    flash[:success] = "Fullfillment email sent successfully."
    redirect_to admin_order_path(@order.id)
  end

  def regenerate_print
    @line_item = LineItem.find(params[:id])
    @line_item.delay.save_image_to_dropbox
    flash[:success] = "Scheduled for regeneration."
    redirect_to admin_order_path(@line_item.order.id)
  end

  protected

    def set_current_tab
      @current_tab = "orders"
    end

end
