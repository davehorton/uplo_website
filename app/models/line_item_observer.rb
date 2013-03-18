class LineItemObserver < ActiveRecord::Observer
  def after_save(line_item)
    update_order(line_item)
  end

  def after_destroy(line_item)
    update_order(line_item)
  end

  private

    def update_order(line_item)
      line_item.order.compute_totals
    end
end
