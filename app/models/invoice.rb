class Invoice < ApplicationRecord

  belongs_to :client
  belongs_to :invoice

  has_many :line_items, dependent: :destroy

  validates :client, presence: true
end
