class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.string :number
      t.datetime :date
      t.datetime :due_date
      t.decimal :subtotal
      t.decimal :iva
      t.decimal :irpf
      t.decimal :total
      t.text :notes
      t.boolean :status

      t.timestamps
    end
  end
end
