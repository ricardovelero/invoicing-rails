class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  validates :quantity, presence: true

  def sub_total
    if item && quantity
      quantity * item.price
    else
      return 0
    end
  end

  def total_price
    if item && quantity
      sub_total * (1 + item.iva / 100)
    else
      return 0
    end
  end

  def total_iva
    if item && quantity
      total_price - sub_total
    else
      return 0
    end
  end
end
