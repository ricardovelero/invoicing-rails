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

  # before_update, not validate: validations run before update opens its
  # transaction, so a lock taken there is released before the UPDATE ever
  # runs and cannot serialize against a concurrent Invoice#assign_number!,
  # which locks this same sequence row via InvoiceSequence#reserve_next!.
  # before_update runs inside update's own transaction, so the lock is held
  # until commit and the two operations block each other instead of racing.
  before_update :prefix_immutable_once_issued, if: :prefix_changed?

  # The series' one counter, created on first use. A series never gets a second
  # one: the unique index refuses it, so numbering cannot restart.
  def sequence
    invoice_sequences.first || create_sequence
  end

  # Display label for the series (prefix + optional name)
  def display_name
    name.present? ? "#{prefix} — #{name}" : prefix
  end

  private

  # requires_new so the losing side of a race can recover: Issue calls this
  # inside its own transaction, and without a savepoint the unique violation
  # aborts that transaction before the rescue can query for the winner's row.
  def create_sequence
    transaction(requires_new: true) do
      invoice_sequences.create!(last_number: 0)
    end
  rescue ActiveRecord::RecordNotUnique
    invoice_sequences.first!
  end

  def normalize_prefix
    self.prefix = prefix.to_s.upcase if prefix.present?
  end

  # display_number reads prefix live off the series, so changing it after the
  # series has issued invoices would silently rewrite their historical numbers.
  # Locks the sequence row first -- the same row a concurrent first Issue
  # locks -- so the two cannot interleave: whichever gets here first makes
  # the other wait, and the loser's re-check below sees a fully committed
  # (or fully absent) result instead of a half-finished one.
  def prefix_immutable_once_issued
    sequence.lock!
    return unless invoices.issued.exists?

    errors.add(:prefix, I18n.t('prefijo_bloqueado'))
    throw :abort
  end
end
