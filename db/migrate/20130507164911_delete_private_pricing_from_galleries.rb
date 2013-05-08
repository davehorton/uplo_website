class DeletePrivatePricingFromGalleries < ActiveRecord::Migration
  def up
    remove_column :galleries, :private_pricing
  end

  def down
  end
end
