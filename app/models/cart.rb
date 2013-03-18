class Cart < ActiveRecord::Base
  belongs_to :order
  belongs_to :user

  has_many :line_items, :through => :order

  delegate :empty?, to: :line_items

  def clear
    line_items.destroy_all
  end
end
