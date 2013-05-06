class Sales
  include ImageConstants

  attr_accessor :image

  def initialize(image)
    self.image = image
  end

  def sold_items_calc(month)
    orders = self.image.orders.completed

    if month
      start_date = DateTime.parse("01 #{month}")
      end_date = TimeCalculator.last_day_of_month(start_date.mon, start_date.year).end_of_day
      end_date = end_date.strftime("%Y-%m-%d %T")
      start_date = start_date.strftime("%Y-%m-%d %T")
      orders = orders.where("transaction_date > ? and transaction_date < ?", start_date, end_date)
    end

    order_ids = orders.collect(&:id)
    sold_items = (orders.length==0) ? [] : self.image.line_items.where(order_id: order_ids)
    sold_items
  end

  def total_image_sales(month = nil)
    total = 0
    sold_items = self.sold_items_calc(month)
    sold_items.each do |item|
      total += ((item.price * item.quantity) * item.commission_percent)
    end
    total
  end

  # mon with year, return sold quantity
  def sold_image_quantity(month = nil)
    result = 0
    sold_items = self.sold_items_calc(month)
    sold_items.each { |item| result += item.quantity }
    return result
  end

  def image_purchase_calc(item_paging_params)
    order_ids = self.image.orders.completed.map(&:id)

    sold_items = []
    if order_ids.any?
      sold_items = LineItem.paginate_and_sort(item_paging_params.merge(sort_expression: 'purchased_date desc')).
        joins("LEFT JOIN orders ON orders.id = line_items.order_id LEFT JOIN users ON users.id = orders.user_id").
        select("line_items.*, users.id as purchaser_id, orders.transaction_date as purchased_date").
        where(image_id: self.image.id, order_id: order_ids)
    end
    sold_items
  end

  def raw_image_purchased_info(item_paging_params = {})
    result = {:data => [], :total => 0}
    self.image_purchase_calc(item_paging_params)
  end

  def image_purchased_info(item_paging_params = {})
    result = {:data => [], :total_quantity => 0, :total_sale => 0}
    sold_items = self.image_purchase_calc(item_paging_params)

    sold_items.each { |item|
      user = User.find_by_id(item.purchaser_id)
      purchased_date = DateTime.parse(item.purchased_date).strftime "%B %d, %Y"
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
