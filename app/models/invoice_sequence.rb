# frozen_string_literal: true

# A counter inside an InvoiceSeries. Holds last_number.
# Exactly one active Sequence per Series at any time, enforced by a
# Postgres partial unique index — never by application code.
class InvoiceSequence < ApplicationRecord
  belongs_to :invoice_series

  validates :active, inclusion: { in: [true, false] }
  validates :last_number, numericality: { greater_than_or_equal_to: 0 }

  # Atomically reserves the next invoice number for this sequence.
  # Must be called inside the caller's transaction.
  # Locks the row (SELECT … FOR UPDATE), increments last_number,
  # and returns the new number.
  #
  # reload(lock: true) rather than a plain re-read: increment! derives its
  # delta from last_number_in_database, so the in-memory record must be fully
  # refreshed from the locked row or the counter jumps by more than one.
  def reserve_next!
    raise 'Sequence is not active' unless active?

    reload(lock: true)
    increment!(:last_number)
    last_number
  end
end
