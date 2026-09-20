class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  validates :quantity, presence: true
  validate :invoice_not_issued

  before_validation :snapshot_item_details, if: :item_id_changed?
  before_destroy :prevent_destruction_if_invoice_issued

  def sub_total
    return 0 unless price && quantity

    quantity * price
  end

  def total_price
    return 0 unless price && quantity

    sub_total * (1 + iva / 100)
  end

  def total_iva
    return 0 unless price && quantity

    total_price - sub_total
  end

  private

  # Items are a catalog: once picked, the line item keeps its own copy of the
  # name/price/iva so a later edit to the Item can't reach back and change
  # what an invoice already says it charged.
  def snapshot_item_details
    return unless item

    self.item_name = item.item_name
    self.price = item.price
    self.iva = item.iva
  end

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
