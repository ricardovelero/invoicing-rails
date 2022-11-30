class Invoice < ApplicationRecord
  
  pg_search_scope :search, against: [:invoice_number, :status, :date, :due_date],
    using: { tsearch: { prefix: true } }

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

  def subtotal
    line_items.sum(&:sub_total)
  end

  def total
    line_items.sum(&:total_price)
  end

  def iva
    line_items.sum(&:total_iva)
  end

  def pdf_line_items
    the_line_items = Array.new
    the_line_items << ["<b>Ítem</b>", "<b>Cantidad</b>", "<b>Importe</b>", "IVA", "<b>Monto</b>"]
    line_items.map do |l|
      line = [l.item.item_name, l.item.price, l.quantity, l.item.iva, (l.item.price * l.quantity * (1 + l.item.iva/100))]
      the_line_items << line
    end
    the_line_items << [nil, nil, nil, "Base Imponible", ActionController::Base.helpers.number_to_currency(subtotal, locale: :es)]
    the_line_items << [nil, nil, nil, "IVA", iva]
    the_line_items << [nil, nil, nil, "TOTAL", ActionController::Base.helpers.number_to_currency(total, locale: :es)]
    return the_line_items
  end

  def pdf
    client = Client.find(client_id)
    user = User.find(user_id)
    Receipts::Invoice.new(
      details: [
        ["Factura #", invoice_number],
        ["Fecha", date.strftime("%B %d, %Y")],
        ["Fecha Vencimiento", due_date.strftime("%B %d, %Y")],
        ["Estatus", "<b><color rgb='#5eba7d'>#{status.upcase}</color></b>"]
      ],
      recipient: [
        "<b>Facturado A:</b>",
        client.full_name,
        client.address_line_1,
        client.address_line_2,
        client.email
      ],
      company: {
        name: user.user_profile.full_name,
        address: user.user_profile.address_line_1+"\n"+user.user_profile.address_line_3,
        phone: user.user_profile.phone,
        email: user.user_profile.email,
        logo: File.expand_path("app/assets/images/facturazen-oso.png")
      },
      line_items: pdf_line_items
    )
  end
end
