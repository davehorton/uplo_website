class AddHasCommissionToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :has_commission, :boolean, :null => false, :default => true
  end
end
