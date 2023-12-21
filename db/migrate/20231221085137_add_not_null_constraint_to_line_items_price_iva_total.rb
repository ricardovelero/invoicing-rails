class AddNotNullConstraintToLineItemsPriceIvaTotal < ActiveRecord::Migration[7.1]
  def change
    change_column :line_items, :price, :decimal, precision: 8, scale: 2, null: false
    change_column :line_items, :iva, :decimal, null: false
    change_column :line_items, :total, :decimal, null: false
  end
end
