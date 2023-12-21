class AddPriceIvaTotalToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :price, :decimal, precision: 8, scale: 2
    add_column :line_items, :iva, :decimal
    add_column :line_items, :total, :decimal
  end
end
