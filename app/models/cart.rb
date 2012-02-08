class Cart < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  
  def empty?
    if self.order and not self.order.line_items.empty?
      false
    else
      true
    end
  end
  
  # A destroyed all items in cart
  def clear
    self.order.line_items.destroy_all
  end
end
