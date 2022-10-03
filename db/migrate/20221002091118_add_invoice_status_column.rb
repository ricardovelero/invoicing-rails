class AddInvoiceStatusColumn < ActiveRecord::Migration[7.0]
  def change
    add_column(:invoices, :status, :string)
  end
end
