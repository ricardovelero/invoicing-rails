require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
    sign_in users(:first)
  end

  test "should get index" do
    get invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    assert_difference("Invoice.count") do
      post invoices_url,
           params: {
             invoice: {
               date: @invoice.date,
               due_date: @invoice.due_date,
               irpf: @invoice.irpf,
               iva: @invoice.iva,
               notes: @invoice.notes,
               status: @invoice.status,
               subtotal: @invoice.subtotal,
               total: @invoice.total,
               client_id: Client.first.id
             }
           }
    end

    assert_redirected_to invoices_url(locale: I18n.locale)
  end

  test "creating invoice as pendiente assigns next correlative number" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    post invoices_url,
         params: {
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             status: 'pendiente',
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id
           }
         }

    assert_redirected_to invoices_url(locale: I18n.locale)
    created_invoice = Invoice.last
    assert_equal original_last + 1, created_invoice.number
    assert_equal invoice_series(:default_a), created_invoice.series
  end

  test "two sequential creates produce n, n+1" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    # First create
    post invoices_url,
         params: {
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             status: 'pendiente',
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id
           }
         }
    first_number = Invoice.last.number

    # Second create
    post invoices_url,
         params: {
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             status: 'pendiente',
             subtotal: 200,
             iva: 42,
             total: 242,
             client_id: clients(:one).id
           }
         }
    second_number = Invoice.last.number

    assert_equal original_last + 1, first_number
    assert_equal original_last + 2, second_number
  end

  test "should show invoice" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    patch invoice_url(@invoice),
          params: {
            invoice: {
              date: @invoice.date,
              due_date: @invoice.due_date,
              irpf: @invoice.irpf,
              iva: @invoice.iva,
              notes: @invoice.notes,
              status: @invoice.status,
              subtotal: @invoice.subtotal,
              total: @invoice.total,
              client_id: Client.first.id
            }
          }
    assert_redirected_to invoices_url(locale: I18n.locale)
  end

  test "should destroy invoice" do
    assert_difference("Invoice.count", -1) { delete invoice_url(@invoice) }

    assert_redirected_to invoices_url(locale: I18n.locale)
  end
end
