class Invoice < ApplicationRecord
  has_one :client
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :items, through: :line_items
  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :client_id, presence: true

  attribute :status, :string, default: "Pendiente"

  before_create :set_invoice_number

  def set_invoice_number
   if Invoice.last.invoice_number.present?
    self.invoice_number = Invoice.last.invoice_number.to_i + 1
   else
    self.invoice_number = Invoice.last.invoice_number
   end
  ensure
  end

end
