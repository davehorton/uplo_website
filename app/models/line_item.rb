class LineItem < ActiveRecord::Base
  include ::SharedMethods::Paging

  belongs_to :order
  belongs_to :image

  def creation_timestamp
    ::Util.distance_of_time_in_words_to_now(self.created_at)
  end
end
