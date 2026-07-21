class AddNameToInvoiceSeries < ActiveRecord::Migration[7.2]
  def change
    add_column :invoice_series, :name, :string
  end
end
