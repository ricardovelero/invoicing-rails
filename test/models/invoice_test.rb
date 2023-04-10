require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  fixtures :invoices
  test "invoice total must be equal to subtotal plus iva% less irpf" do
    invoice = Invoice.all.sample()
    iva = invoice.subtotal * invoice.iva / 100
    irpf = invoice.subtotal * invoice.irpf / 100
    total = invoice.subtotal + iva - irpf
    assert invoice.invalid?
    assert_equal(invoice.total, total)
  end
end
