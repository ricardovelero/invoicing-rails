# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user
  has_many :line_items
  has_many :invoices, through: :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :item_name, :price, :iva, presence: true
  validates :item_name, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 300 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :iva, numericality: { greater_than_or_equal_to: 0 }

  pg_search_scope :search,
                  against: %i[item_name description price iva],
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  private

  # ensure that there are no line items referencing this item
  def ensure_not_referenced_by_any_line_item
    return if line_items.empty?

    errors.add(:base, 'Ítem presente en una Factura')
    throw :abort
  end
end
