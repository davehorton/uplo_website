class LineItem < ActiveRecord::Base
  include ::SharedMethods::Paging

  belongs_to :order
  belongs_to :image
  after_save :update_oder
  after_destroy :update_oder

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end

  def update_oder
    self.order.compute_totals
  end
end
