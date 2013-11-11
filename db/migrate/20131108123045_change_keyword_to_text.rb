class ChangeKeywordToText < ActiveRecord::Migration
  def up
    change_column :galleries, :keyword, :text
    change_column :images, :keyword, :text
  end

  def down
    change_column :galleries, :keyword, :string
    change_column :images, :keyword, :string
  end
end
