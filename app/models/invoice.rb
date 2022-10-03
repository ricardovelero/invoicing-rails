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
    last_invoice = Invoice.last
    if last_invoice.nil?
      self.invoice_number = 1
    else
      if Invoice.last.invoice_number.to_i
        self.invoice_number = Invoice.last.invoice_number.to_i + 1
      else
        self.invoice_number = Invoice.last.invoice_number
      end
    end
  end
end
