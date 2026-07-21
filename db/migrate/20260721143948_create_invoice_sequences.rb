class CreateInvoiceSequences < ActiveRecord::Migration[7.2]
  def change
    create_table :invoice_sequences do |t|
      t.references :invoice_series, null: false, foreign_key: true
      t.integer :last_number, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string :year_label

      t.timestamps
    end

    # Partial unique index: enforce exactly one active sequence per series
    add_index :invoice_sequences, :invoice_series_id,
              unique: true,
              where: 'active',
              name: 'index_invoice_sequences_one_active_per_series'
  end
end
