class BackfillInvoiceSeriesAndSequences < ActiveRecord::Migration[7.2]
  def up
    # Find all users who have invoices
    User.joins(:invoices).distinct.find_each do |user|
      # Create default series "A"
      series = InvoiceSeries.create!(user: user, prefix: 'A')

      # Get user's invoices ordered by invoice_number
      user_invoices = user.invoices.order(:invoice_number)
      max_number = user_invoices.maximum(:invoice_number).to_i

      # Create active sequence with counter at max
      sequence = InvoiceSequence.create!(
        invoice_series: series,
        last_number: max_number,
        active: true
      )

      # Backfill each invoice's series_id and number
      user_invoices.each do |invoice|
        num = invoice.invoice_number.to_i
        # Skip invoices with NULL or non-numeric invoice_number
        next if num == 0 && invoice.invoice_number.blank?
        invoice.update_columns(series_id: series.id, number: num)
      end
    end
  end

  def down
    Invoice.update_all(series_id: nil, number: nil)
    InvoiceSequence.delete_all
    InvoiceSeries.delete_all
  end
end
