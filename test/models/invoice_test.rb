require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  fixtures :invoices

  test "invoice total must be equal to subtotal plus iva% less irpf" do
    invoice = invoices(:one)
    iva = invoice.subtotal * invoice.iva / 100
    irpf = invoice.subtotal * invoice.irpf / 100
    total = invoice.subtotal + iva - irpf
    assert invoice.valid?
    assert_equal(invoice.total, total)
  end

  test "display_number returns composed string like A-0100" do
    invoice = invoices(:one)
    assert_equal "A-0100", invoice.display_number
  end

  test "display_number returns nil when no series or number" do
    invoice = Invoice.new
    assert_nil invoice.display_number
  end

  test "assign_number! assigns next correlative number from default scope" do
    user = users(:first)
    series = invoice_series(:default_a)
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    invoice = Invoice.create!(
      user: user,
      client: clients(:one),
      date: Date.today,
      due_date: Date.today + 30,
      status: 'pendiente',
      subtotal: 100,
      iva: 21,
      total: 121
    )

    Invoice.transaction do
      invoice.assign_number!
    end

    assert_equal series, invoice.series
    assert_equal original_last + 1, invoice.number
  end

  test "assign_number! assigns next correlative number from a specific scope" do
    user = users(:first)
    other_series = InvoiceSeries.create!(user: user, prefix: 'B')
    other_seq = other_series.active_sequence

    invoice = Invoice.create!(
      user: user,
      client: clients(:one),
      date: Date.today,
      due_date: Date.today + 30,
      status: 'pendiente',
      subtotal: 100,
      iva: 21,
      total: 121
    )

    Invoice.transaction do
      invoice.assign_number!(other_series)
    end

    assert_equal other_series, invoice.series
    assert_equal 1, invoice.number
  end

  test "assign_number! creates series lazily for new user" do
    user = users(:second)
    # User second has no invoice_series yet
    assert_equal 0, user.invoice_series.count

    invoice = Invoice.create!(
      user: user,
      client: clients(:one),
      date: Date.today,
      due_date: Date.today + 30,
      status: 'pendiente',
      subtotal: 50,
      iva: 10.5,
      total: 60.5
    )

    Invoice.transaction do
      invoice.assign_number!
    end

    assert_equal 1, user.invoice_series.count
    series = user.invoice_series.first
    assert_equal 'A', series.prefix
    assert_equal series, invoice.series
    assert_equal 1, invoice.number
  end

  test "failed save does not burn a number" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    # Try to create an invalid invoice inside a transaction that assigns a number
    invoice = Invoice.new(
      user: users(:first),
      client_id: nil, # invalid - no client
      date: Date.today,
      due_date: Date.today + 30,
      status: 'pendiente'
    )

    assert_not invoice.valid?
    # The sequence counter should remain unchanged
    assert_equal original_last, sequence.reload.last_number
  end
end
