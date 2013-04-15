class SizeSerializer < ActiveModel::Serializer
  attributes :id, :minimum_recommended_resolution, :aspect_ratio
  attribute :to_name, :key => :name
end
