class ConvertTierToTierId < ActiveRecord::Migration
  def up
    add_column :images, :convert_tier, :integer

    Image.reset_column_information

    Image.all.each do |i|
      i.convert_tier = i.tier.to_i
      i.save!
    end

    remove_column :images, :tier
    rename_column :images, :convert_tier, :tier_id
    add_index :images, :tier_id
  end

  def down
  end
end
