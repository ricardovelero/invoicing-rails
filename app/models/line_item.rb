class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  def sub_total
    if item
      quantity * item.price
    end
  end

  def total_price
    if item
      sub_total * (1 + item.iva / 100)
    end
  end

  def total_iva
    if item
      total_price - sub_total
    end
  end
end
