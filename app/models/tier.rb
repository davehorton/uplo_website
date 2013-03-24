class Tier < ActiveRecord::Base
  validates :name, presence: true
  default_scope order('tiers.name')
end
