class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  validates :quantity, presence: true
  validate :invoice_not_issued

  before_destroy :prevent_destruction_if_invoice_issued

  def sub_total
    return 0 unless item && quantity

    quantity * item.price
  end

  def total_price
    return 0 unless item && quantity

    sub_total * (1 + item.iva / 100)
  end

  def total_iva
    return 0 unless item && quantity

    total_price - sub_total
  end

  private

  # Line items are the invoice's content, so they freeze with it. Same rule as
  # Invoice#immutable_once_issued: the invoice is issued once it holds a Number
  # in the database.
  def invoice_issued?
    invoice.present? && !invoice.number_in_database.nil?
  end

  def invoice_not_issued
    return unless invoice_issued?

    errors.add(:base, I18n.t('invoice.update_blocked'))
  end

  def prevent_destruction_if_invoice_issued
    return unless invoice_issued?

    errors.add(:base, I18n.t('invoice.update_blocked'))
    throw :abort
  end
end
