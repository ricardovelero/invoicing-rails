# frozen_string_literal: true

# A user-owned series of invoices identified by a prefix (e.g. "A", "R").
# Equivalent to the Spanish legal concept of "serie".
class InvoiceSeries < ApplicationRecord
  belongs_to :user
  has_many :invoice_sequences, dependent: :destroy
  has_many :invoices, dependent: :nullify

  validates :prefix, presence: true,
                     uniqueness: { scope: :user_id, case_sensitive: false }

  # Returns the active sequence for this series, creating one lazily if none exists.
  def active_sequence
    invoice_sequences.find_by(active: true) ||
      begin
        invoice_sequences.create!(active: true, last_number: 0)
      rescue ActiveRecord::RecordNotUnique
        invoice_sequences.find_by!(active: true)
      end
  end
end
