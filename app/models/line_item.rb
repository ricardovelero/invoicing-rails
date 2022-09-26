class LineItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
end
