class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
end
