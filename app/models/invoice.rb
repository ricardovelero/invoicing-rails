# frozen_string_literal: true

# Invoice model including search with association
class Invoice < ApplicationRecord # rubocop:disable Metrics/ClassLength
  belongs_to :client
  belongs_to :user
  belongs_to :series, class_name: 'InvoiceSeries', optional: true

  has_many :line_items, dependent: :destroy
  has_many :items, through: :line_items
  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :client_id, presence: true

  attribute :status, :string, default: 'borrador'

  STATUSES = %w[borrador pendiente pagada].freeze
  validates :status, inclusion: { in: STATUSES }

  scope :for_account, ->(user_id) { where(user_id:) }

  scope :filter_status, ->(status) { where(status:) }

  scope :due, -> { where('due_date <= ?', Date.today) }
  scope :about_to_be_due, -> { where('due_date = ?', Date.tomorrow) }

  pg_search_scope :search,
                  against: %i[status notes],
                  associated_against: {
                    client: %i[first_name last_name]
                  },
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  def draft?
    status == 'borrador'
  end

  def issued?
    %w[pendiente pagada].include?(status)
  end

  # Transitions draft to pendiente, reserving the next correlative number atomically.
  # Must be called inside a transaction.
  def issue!
    raise 'Invoice is not a draft' unless draft?

    assign_number!
    update!(status: 'pendiente')
  end

  # Prevents destruction of issued invoices
  def prevent_destruction_if_issued
    return if draft?

    errors.add(:base, I18n.t('invoice.destroy_blocked'))
    throw :abort
  end

  before_destroy :prevent_destruction_if_issued

  def client_full_name
    Client.find(client_id).full_name
  end

  # Composed display string like "A-0042"
  def display_number
    return nil unless series && number

    "#{series.prefix}-#{number.to_s.rjust(4, '0')}"
  end

  # Assigns the next correlative number from the given scope (or the user's
  # default scope "A" if none is provided). Creates the scope and sequence
  # lazily if they don't exist. Must be called inside a transaction.
  def assign_number!(scope = nil)
    target_series = scope || user.invoice_series.find_or_create_by!(prefix: 'A')
    sequence = target_series.active_sequence
    next_number = sequence.reserve_next!
    update!(series: target_series, number: next_number)
  end

  scope :issued, -> { where.not(status: 'borrador') }

  def self.total_invoice_count
    issued.count
  end

  def self.total_draft_count
    filter_status('borrador').count
  end

  def self.total_paid_count
    filter_status('pagada').count
  end

  def self.total_not_paid_count
    filter_status('pendiente').count
  end

  def self.total_due_count
    issued.due.count
  end

  def self.total_about_to_be_due_count
    issued.about_to_be_due.count
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
    return 'not-paid' if status == 'pendiente'
    return 'draft' if status == 'borrador'

    nil
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
        [I18n.t('factura') + ' #', display_number],
        [I18n.t('fecha'), date.strftime('%B %d, %Y')],
        [I18n.t('fecha_vencimiento'), due_date.strftime('%B %d, %Y')],
        [I18n.t('estatus'), "<b><color rgb='#5eba7d'>#{status.upcase}</color></b>"]
      ],
      recipient: [
        I18n.t('facturado_a'),
        client.full_name,
        client.address_line1,
        client.address_line2,
        client.email
      ],
      company: {
        name: user.user_profile.full_name,
        address: user.user_profile.address_line1 + "\n" + user.user_profile.address_line_3,
        phone: user.user_profile.phone,
        email: user.user_profile.email,
        logo: File.expand_path('app/assets/images/logo.png')
      },
      line_items: pdf_line_items,
      footer: notes
    )
  end
end
