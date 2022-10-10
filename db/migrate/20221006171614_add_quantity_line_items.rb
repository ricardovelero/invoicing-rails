class AddQuantityLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column(:line_items, :quantity, :float, null: false)
  end
end
