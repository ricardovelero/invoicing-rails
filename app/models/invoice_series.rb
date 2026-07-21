# frozen_string_literal: true

# A user-owned series of invoices identified by a prefix (e.g. "A", "R").
# Equivalent to the Spanish legal concept of "serie".
class InvoiceSeries < ApplicationRecord
  belongs_to :user
  has_many :invoice_sequences, dependent: :destroy
  has_many :invoices, foreign_key: :series_id, dependent: :nullify

  before_validation :normalize_prefix

  validates :prefix, presence: true,
                     format: { with: /\A[A-Za-z0-9]+\z/, message: ->(*_args) { I18n.t('prefijo_formato') } },
                     uniqueness: { scope: :user_id }

  # Returns the active sequence for this series, creating one lazily if none exists.
  def active_sequence
    invoice_sequences.find_by(active: true) ||
      begin
        invoice_sequences.create!(active: true, last_number: 0)
      rescue ActiveRecord::RecordNotUnique
        invoice_sequences.find_by!(active: true)
      end
  end

  # Closes the active Sequence and opens a fresh one (counter restarting at 1).
  # Atomic: the one-active-per-scope invariant is guaranteed by the DB partial
  # unique index even under races.
  def rollover!
    transaction do
      current = invoice_sequences.where(active: true).lock('FOR UPDATE').first
      current&.update!(active: false)
      invoice_sequences.create!(active: true, last_number: 0)
    end
  rescue ActiveRecord::RecordNotUnique
    # Another transaction already created the new active sequence
    invoice_sequences.find_by!(active: true)
  end

  # Display label for the scope (prefix + optional name)
  def display_name
    name.present? ? "#{prefix} — #{name}" : prefix
  end

  private

  def normalize_prefix
    self.prefix = prefix.to_s.upcase if prefix.present?
  end
end
