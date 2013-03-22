class ChangePromoteNumToBoolean < ActiveRecord::Migration
  def up
    add_column :images, :convert_promote_num, :boolean, :default => false

    Image.reset_column_information

    Image.all.each do |i|
      i.convert_promote_num = i.promote_num == 1
      i.save!
    end

    remove_column :images, :promote_num
    rename_column :images, :convert_promote_num, :promote
  end

  def down
  end
end
