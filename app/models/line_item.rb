class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  validates :quantity, presence: true

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
end
