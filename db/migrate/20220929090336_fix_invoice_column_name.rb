class FixInvoiceColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :invoices, :number, :invoice_number
  end
end
