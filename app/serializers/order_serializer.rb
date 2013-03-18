class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :tax, :price_total, :order_total, :transaction_code, :transaction_date, :transaction_status,
             :first_name, :last_name, :address, :message, :city, :zip_code, :card_type, :card_number, :expiration, :cvv
  has_many :images
end
