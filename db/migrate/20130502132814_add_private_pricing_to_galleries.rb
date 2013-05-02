class AddPrivatePricingToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :private_pricing, :decimal, :precision => 16, :scale => 2, default: 0.00
  end
end
