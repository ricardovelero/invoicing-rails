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
  def reserve_next!
    raise 'Sequence is not active' unless active?

    # Lock the row AND refresh in-memory attributes from the locked row
    locked = self.class.where(id: id).lock('FOR UPDATE').first!
    self.last_number = locked.last_number

    increment!(:last_number)
    last_number
  end
end
