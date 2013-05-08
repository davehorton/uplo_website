class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :tax, :price_total, :order_total,
             :transaction_code, :transaction_date, :transaction_status
  has_many :line_items
end
