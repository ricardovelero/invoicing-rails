class RemoveInvoiceStatusColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column(:invoices, :status)
  end
end
