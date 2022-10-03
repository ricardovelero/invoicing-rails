class SetBooleanStatusToClientAndInvoice < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:invoices, :status, "true")
    change_column_default(:clients, :active, "true")
  end
end
