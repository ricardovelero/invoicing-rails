class Item < ApplicationRecord
  validates :title, :price, presence: true
  validates :title, uniqueness: true, length: { maximum: 100 }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :tax1, numericality: { greater_than_or_equal_to: 0.01 }
  validates :tax2, numericality: { greater_than_or_equal_to: 0.01 }
end
