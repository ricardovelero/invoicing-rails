class Item < ApplicationRecord
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  private
    #ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
        errors.add(:base, 'Ítem presente en una Factura')
        throw :abort
      end
    end

  validates :title, :price, presence: true
  validates :title, uniqueness: true, length: { maximum: 100 }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :tax1, numericality: { greater_than_or_equal_to: 0.01 }
  validates :tax2, numericality: { greater_than_or_equal_to: 0.01 }
end
