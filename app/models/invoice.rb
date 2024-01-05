# frozen_string_literal: true

# Invoice model including search with association
class Invoice < ApplicationRecord # rubocop:disable Metrics/ClassLength
  belongs_to :client
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :items, through: :line_items
  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :client_id, presence: true

  attribute :status, :string, default: 'pendiente'

  before_create :set_invoice_number

  scope :for_account, ->(user_id) { where(user_id:) }

  scope :filter_status, ->(status) { where(status:) }

  scope :due, -> { where('due_date <= ?', Date.today) }
  scope :about_to_be_due, -> { where('due_date = ?', Date.tomorrow) }

  pg_search_scope :search,
                  against: %i[invoice_number status notes],
                  associated_against: {
                    client: %i[first_name last_name]
                  },
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  def client_full_name
    Client.find(client_id).full_name
  end

  def set_invoice_number
    last_invoice = Invoice.last
    self.invoice_number = if last_invoice.nil?
                            1
                          elsif Invoice.last.invoice_number.to_i
                            Invoice.last.invoice_number.to_i + 1
                          else
                            Invoice.last.invoice_number
                          end
  end

  def self.total_invoice_count
    count
  end

  def self.total_paid_count
    filter_status('pagada').count
  end

  def self.total_not_paid_count
    filter_status('pendiente').count
  end

  def self.total_due_count
    due.count
  end

  def self.total_about_to_be_due_count
    about_to_be_due.count
  end

  def sum_subtotal
    line_items.sum(&:sub_total)
  end

  def sum_total
    line_items.sum(&:total_price)
  end

  def sum_iva
    line_items.sum(&:total_iva)
  end

  def past_due?
    return 'past-due' if due_date.past?

    'on-time'
  end

  def status?
    return 'paid' if status == 'pagada'

    'not-paid' if status == 'pendiente'
  end

  def pdf_line_items
    the_line_items = []
    the_line_items << ['<b>' + I18n.t('item') + '</b>', '<b>' + I18n.t('cantidad') + '</b>', '<b>' + I18n.t('importe') + '</b>',
                       '<b>' + I18n.t('iva') + '</b>', '<b>' + I18n.t('monto') + '</b>']
    line_items.map do |l|
      line = [l.item.item_name, l.quantity, ActionController::Base.helpers.number_to_currency(l.item.price),
              l.item.iva, ActionController::Base.helpers.number_to_currency((l.item.price * l.quantity * (1 + l.item.iva / 100)))]
      the_line_items << line
    end
    the_line_items << [nil, nil, nil, I18n.t('subtotal'), ActionController::Base.helpers.number_to_currency(subtotal)]
    the_line_items << [nil, nil, nil, I18n.t('iva'), ActionController::Base.helpers.number_to_currency(iva)]
    the_line_items << [nil, nil, nil, 'TOTAL', ActionController::Base.helpers.number_to_currency(total)]
    the_line_items
  end

  def pdf
    client = Client.find(client_id)
    user = User.find(user_id)
    Receipts::Invoice.new(
      title: I18n.t('factura'),
      details: [
        [I18n.t('factura') + ' #', invoice_number],
        [I18n.t('fecha'), date.strftime('%B %d, %Y')],
        [I18n.t('fecha_vencimiento'), due_date.strftime('%B %d, %Y')],
        [I18n.t('estatus'), "<b><color rgb='#5eba7d'>#{status.upcase}</color></b>"]
      ],
      recipient: [
        I18n.t('facturado_a'),
        client.full_name,
        client.address_line_1,
        client.address_line_2,
        client.email
      ],
      company: {
        name: user.user_profile.full_name,
        address: user.user_profile.address_line_1 + "\n" + user.user_profile.address_line_3,
        phone: user.user_profile.phone,
        email: user.user_profile.email,
        logo: File.expand_path('app/assets/images/logo.png')
      },
      line_items: pdf_line_items,
      footer: notes
    )
  end
end
