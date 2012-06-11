class AddKeywordToImage < ActiveRecord::Migration
  def change
    add_column :images, :keyword, :string
    add_column :images, :is_owner_avatar, :boolean
  end
end
