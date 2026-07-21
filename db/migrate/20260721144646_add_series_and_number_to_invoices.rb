class AddSeriesAndNumberToInvoices < ActiveRecord::Migration[7.2]
  def change
    add_reference :invoices, :series, foreign_key: { to_table: :invoice_series }
    add_column :invoices, :number, :integer
    add_index :invoices, %i[series_id number], unique: true
  end
end
