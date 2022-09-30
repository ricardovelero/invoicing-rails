class Invoice < ApplicationRecord
  has_one :client
  belongs_to :user

  has_many :items, through: :line_items, dependent: :destroy

  validates :client_id, presence: true
end
