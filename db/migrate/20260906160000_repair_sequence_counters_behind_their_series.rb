# frozen_string_literal: true

# 20260721144700 seeded each counter from `maximum(:invoice_number)` on what
# was a string column, so the maximum was lexicographic: for invoices numbered
# 1..101 it returned '99', leaving the counter 2 behind the series. The next
# Issue then hands out a Number the series already holds and dies on
# index_invoices_on_series_id_and_number, permanently, until the counter is
# repaired -- which is what this does.
#
# Raw SQL rather than the models on purpose: a data migration that reaches for
# InvoiceSequence breaks the day that model changes, which is exactly how the
# migration above came to reference a column that no longer exists.
#
# A no-op on any database whose counters are correct.
class RepairSequenceCountersBehindTheirSeries < ActiveRecord::Migration[7.2]
  def up
    repaired = execute(REPAIR)
    repaired.each { |row| say "series #{row['invoice_series_id']}: counter moved up to #{row['last_number']}" }
    say "#{repaired.count} counter(s) repaired"
  end

  # Nothing to reverse: the previous values were wrong, and restoring them
  # would re-break the series.
  def down; end

  REPAIR = <<~SQL.squish
    UPDATE invoice_sequences AS s
       SET last_number = held.max_number,
           updated_at  = NOW()
      FROM (
            SELECT series_id, MAX(number) AS max_number
              FROM invoices
             WHERE number IS NOT NULL
             GROUP BY series_id
           ) AS held
     WHERE held.series_id = s.invoice_series_id
       AND s.last_number < held.max_number
    RETURNING s.invoice_series_id, s.last_number
  SQL
end
