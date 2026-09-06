# frozen_string_literal: true

# A counter inside an InvoiceSeries. Holds last_number.
# Exactly one active Sequence per Series at any time, enforced by a
# Postgres partial unique index — never by application code.
class InvoiceSequence < ApplicationRecord
  # Raised when a Number is asked of a retired sequence. Nothing deactivates a
  # sequence today, so this means the row was tampered with.
  Inactive = Class.new(StandardError)

  belongs_to :invoice_series

  validates :active, inclusion: { in: [true, false] }
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
    raise Inactive unless active?

    reload(lock: true)
    increment!(:last_number)
    last_number
  end
end
