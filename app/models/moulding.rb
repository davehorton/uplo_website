class Moulding < ActiveRecord::Base
  validates :name, presence: true
  default_scope order('mouldings.id')
end
