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
  
  # A destroyed cart automatically gets created again
  def clear
    unless self.empty?
      self.destroy
    end
  end
end
