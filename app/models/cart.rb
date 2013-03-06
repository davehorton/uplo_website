class Cart < ActiveRecord::Base
  belongs_to :order
  belongs_to :user

  def clear
    self.order.line_items.destroy_all
  end

  def empty?
    if self.order and not self.order.line_items.empty?
      false
    else
      true
    end
  end
end
