class SetTotalsToZero < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:invoices, :total, 0)
    change_column_default(:invoices, :subtotal, 0)
    change_column_default(:invoices, :iva, 0)
    change_column_default(:invoices, :irpf, 0)
  end
end
