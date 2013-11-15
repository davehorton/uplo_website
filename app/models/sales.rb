class Sales
  include ImageConstants

  attr_accessor :image

  def initialize(image)
    self.image = image
  end

  def sold_items(month = nil)
    orders = self.image.orders.completed

    if month
      start_date = DateTime.parse("01 #{month}")
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).end_of_day
      end_date = end_date.strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = orders.where("transaction_date > ? and transaction_date < ?", start_date, end_date)
    end

    order_ids = orders.collect(&:id)
    (orders.length==0) ? [] : self.image.line_items.where(order_id: order_ids)
  end

  def total_image_sales(month = nil)
    total = 0
    sold_items = self.sold_items(month)
    sold_items.each do |item|
      if item.commission_percent
        total += ((item.price * item.quantity) * item.commission_percent/100)
      else
        total += ((item.price * item.quantity))
      end
    end
    total
  end

  # mon with year, return sold quantity
  def sold_image_quantity(month = nil)
    self.sold_items(month).sum(&:quantity)
  end

  def raw_image_purchased(item_paging_params = {})
    order_ids = self.image.orders.completed.pluck(:id)

    sold_items = []
    if order_ids.any?
      sold_items = LineItem.paginate_and_sort(item_paging_params.merge(sort_expression: 'orders.transaction_date desc')).
        includes(:order => :user).
        where(image_id: self.image.id, order_id: order_ids)
    end
    sold_items
  end

  def image_purchased_info(item_paging_params = {})
    result = {:data => [], :total_quantity => 0, :total_sale => 0}
    sold_items = self.raw_image_purchased(item_paging_params)

    sold_items.each { |item|
      user = item.order.user
      purchased_date = DateTime.parse((item.order.transaction_date).strftime "%B %d, %Y")
      result[:data] << {
        :username => user.try(:username) || 'Deleted',
        :plexi_mount => item.plexi_mount ? 'Plexi Mount' : 'No Plexi Mount',
        :size => item.size,
        :quantity => item.quantity,
        :moulding => item.moulding,
        :date => purchased_date,
        :avatar_url => user.avatar_url,
        :user_id => user.try(:id)
      }
      result[:total_quantity] += item.quantity
      result[:total_sale] += (item.quantity *  item.price)/2
    }

    result
  end

  # return sold quantity
  def image_monthly_sales_over_year(current_date, options = {:report_by => SALE_REPORT_TYPE[:price]})
    result = []
    date = DateTime.parse current_date.to_s
    prior_months = TimeCalculator.prior_year_period(date, {:format => '%b %Y'})
    prior_months.each { |mon|
      short_mon = DateTime.parse(mon).strftime('%b')
      if options.nil?
        result << { :month => short_mon, :sales => self.total_image_sales(mon) }
      elsif options.has_key?(:report_by)
        result << {
          :month => short_mon,
          :sales => (options[:report_by]==SALE_REPORT_TYPE[:price]) ? total_image_sales(mon) : sold_image_quantity(mon)
        }
      end
    }
    return result
  end

end
