# frozen_string_literal: true

# A counter inside an InvoiceSeries. Holds last_number.
# Exactly one Sequence per Series, for the life of the Series, enforced by a
# Postgres unique index — never by application code. A Series that could swap
# counters could restart its numbering, which Art. 6.1.a RD 1619/2012 forbids.
class InvoiceSequence < ApplicationRecord
  belongs_to :invoice_series

  validates :last_number, numericality: { greater_than_or_equal_to: 0 }

  # Atomically reserves the next invoice number for this sequence.
  # Locks the row (SELECT … FOR UPDATE), increments last_number,
  # and returns the new number. The lock is only worth holding inside a
  # transaction, which is why both callers open one -- see Invoice#issue!.
  #
  # reload(lock: true) rather than a plain re-read: increment! derives its
  # delta from last_number_in_database, so the in-memory record must be fully
  # refreshed from the locked row or the counter jumps by more than one.
  def reserve_next!
    reload(lock: true)
    increment!(:last_number)
    last_number
  end
end
