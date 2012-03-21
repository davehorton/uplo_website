class LineItem < ActiveRecord::Base
  include ::SharedMethods::Paging

  belongs_to :order
  belongs_to :image
end
