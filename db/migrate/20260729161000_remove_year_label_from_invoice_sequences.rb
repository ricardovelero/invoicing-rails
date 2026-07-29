# frozen_string_literal: true

# Cosmetic label from the removed Rollover feature. Never written by any code
# path, so there is nothing to preserve.
class RemoveYearLabelFromInvoiceSequences < ActiveRecord::Migration[7.2]
  def change
    remove_column :invoice_sequences, :year_label, :string
  end
end
