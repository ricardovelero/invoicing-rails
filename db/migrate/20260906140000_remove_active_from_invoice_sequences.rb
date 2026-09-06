# frozen_string_literal: true

# The active flag existed to support rollover: retire a counter, start a fresh
# one under the same prefix. Rollover was removed as non-compliant with
# Art. 6.1.a RD 1619/2012 (cd76e7c), but the flag outlived it, and with it the
# mechanism -- InvoiceSeries#active_sequence replaced any counter it found
# deactivated, restarting a series at 1. A series can hold exactly one counter
# forever, so the cardinality belongs in a plain unique index and the flag
# carries no information.
class RemoveActiveFromInvoiceSequences < ActiveRecord::Migration[7.2]
  def change
    remove_index :invoice_sequences, :invoice_series_id,
                 unique: true, where: 'active',
                 name: 'index_invoice_sequences_one_active_per_series'
    remove_index :invoice_sequences, :invoice_series_id,
                 name: 'index_invoice_sequences_on_invoice_series_id'
    remove_column :invoice_sequences, :active, :boolean, default: true, null: false
    add_index :invoice_sequences, :invoice_series_id, unique: true
  end
end
