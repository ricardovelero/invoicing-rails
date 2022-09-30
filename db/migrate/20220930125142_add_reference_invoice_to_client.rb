class AddReferenceInvoiceToClient < ActiveRecord::Migration[7.0]
  def change
    add_reference :invoices, :client, index: true
  end
end
