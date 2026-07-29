# frozen_string_literal: true

# A user-owned series of invoices identified by a prefix (e.g. "A", "R").
# Equivalent to the Spanish legal concept of "serie".
class InvoiceSeries < ApplicationRecord
  belongs_to :user
  has_many :invoice_sequences, dependent: :destroy
  # restrict, never nullify: detaching invoices from their series would strip
  # the prefix off numbers that are already on issued documents.
  has_many :invoices, foreign_key: :series_id, dependent: :restrict_with_error

  before_validation :normalize_prefix

  validates :prefix, presence: true,
                     format: { with: /\A[A-Za-z0-9]+\z/, message: ->(*_args) { I18n.t('prefijo_formato') } },
                     uniqueness: { scope: :user_id }

  # Returns the active sequence for this series, creating one lazily if none exists.
  def active_sequence
    invoice_sequences.find_by(active: true) || create_active_sequence
  end

  # Display label for the series (prefix + optional name)
  def display_name
    name.present? ? "#{prefix} — #{name}" : prefix
  end

  private

  # requires_new so the losing side of a race can recover: Issue calls this
  # inside its own transaction, and without a savepoint the unique violation
  # aborts that transaction before the rescue can query for the winner's row.
  def create_active_sequence
    transaction(requires_new: true) do
      invoice_sequences.create!(active: true, last_number: 0)
    end
  rescue ActiveRecord::RecordNotUnique
    invoice_sequences.find_by!(active: true)
  end

  def normalize_prefix
    self.prefix = prefix.to_s.upcase if prefix.present?
  end
end
