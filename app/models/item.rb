class Item < ApplicationRecord
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :item_name, :price, :iva, presence: true
  validates :item_name, uniqueness: true, length: { maximum: 100 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :iva, numericality: { greater_than_or_equal_to: 0 }
  validates :irpf, numericality: { greater_than_or_equal_to: 0 }

  private
    #ensure that there are no line items referencing this item
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
        errors.add(:base, 'Ítem presente en una Factura')
        throw :abort
      end
    end
end
