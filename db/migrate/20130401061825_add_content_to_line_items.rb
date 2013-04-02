class AddContentToLineItems < ActiveRecord::Migration
  def up
    add_attachment :line_items, :content
  end

  def down
    remove_attachment :line_items, :content
  end
end
