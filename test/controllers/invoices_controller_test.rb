require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
    @draft = invoices(:draft_one)
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

  test "should create invoice as draft" do
    assert_difference("Invoice.count") do
      post invoices_url,
           params: {
             save_draft: true,
             invoice: {
               date: @invoice.date,
               due_date: @invoice.due_date,
               irpf: @invoice.irpf,
               iva: @invoice.iva,
               notes: @invoice.notes,
               subtotal: @invoice.subtotal,
               total: @invoice.total,
               client_id: Client.first.id
             }
           }
    end

    assert_redirected_to invoices_url(locale: I18n.locale)
    created = Invoice.last
    assert_equal 'borrador', created.status
    assert_nil created.number
    assert_nil created.series
  end

  test "should create invoice as pendiente via save_and_issue" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    assert_difference("Invoice.count") do
      post invoices_url,
           params: {
             save_and_issue: true,
             invoice: {
               date: Date.today,
               due_date: @invoice.due_date,
               irpf: @invoice.irpf,
               iva: @invoice.iva,
               notes: @invoice.notes,
               subtotal: @invoice.subtotal,
               total: @invoice.total,
               client_id: Client.first.id
             }
           }
    end

    assert_redirected_to invoices_url(locale: I18n.locale)
    created = Invoice.last
    assert_equal 'pendiente', created.status
    assert_equal original_last + 1, created.number
  end

  test "should create invoice (legacy test with status param)" do
    assert_difference("Invoice.count") do
      post invoices_url,
           params: {
             save_and_issue: true,
             invoice: {
               date: Date.today,
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
           save_and_issue: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
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

  test "creating invoice with specific series uses that series' sequence" do
    user = users(:first)
    other_series = InvoiceSeries.create!(user: user, prefix: 'B')
    other_seq = other_series.active_sequence

    post invoices_url,
         params: {
           save_and_issue: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id,
             series_id: other_series.id
           }
         }

    assert_redirected_to invoices_url(locale: I18n.locale)
    created_invoice = Invoice.last
    assert_equal other_series, created_invoice.series
    assert_equal 1, created_invoice.number
  end

  test "cannot create an invoice in another user's series" do
    foreign_series = InvoiceSeries.create!(user: users(:second), prefix: 'Z')

    assert_no_difference("Invoice.count") do
      post invoices_url,
           params: {
             save_and_issue: true,
             invoice: {
               date: Date.today,
               due_date: Date.today + 30,
               subtotal: 100,
               iva: 21,
               total: 121,
               client_id: clients(:one).id,
               series_id: foreign_series.id
             }
           }
    end

    assert_response :unprocessable_entity
  end

  test "backdating invoice does not change which sequence supplies its number" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    post invoices_url,
         params: {
           save_and_issue: true,
           invoice: {
             date: 5.days.ago,
             due_date: Date.today + 30,
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
           save_and_issue: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
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
           save_and_issue: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
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

  test "draft creation does not move sequence counter" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    post invoices_url,
         params: {
           save_draft: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id
           }
         }

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_equal original_last, sequence.reload.last_number
    assert_nil Invoice.last.number
  end

  test "cannot create and issue an invoice with no dates" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    assert_no_difference("Invoice.count") do
      post invoices_url, params: { save_and_issue: true, invoice: { client_id: clients(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_equal original_last, sequence.reload.last_number

    # The invoice list used to die on the dateless row this request created.
    get invoices_url
    assert_response :success
  end

  test "cannot create and issue an invoice dated before the last one in the series" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    assert_no_difference("Invoice.count") do
      post invoices_url,
           params: {
             save_and_issue: true,
             invoice: {
               date: 2.years.ago,
               due_date: Date.today + 30,
               subtotal: 100,
               iva: 21,
               total: 121,
               client_id: clients(:one).id
             }
           }
    end

    assert_response :unprocessable_entity
    assert_match I18n.t('invoice.backdated'), response.body
    assert_equal original_last, sequence.reload.last_number
  end

  test "a rejected create still renders a form that would create, not update" do
    # A backdated issue fails *after* the insert, so this is the path where the
    # record has to come back out of the rolled-back transaction as new again.
    post invoices_url,
         params: {
           save_and_issue: true,
           invoice: {
             date: 2.years.ago,
             due_date: Date.today + 30,
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id
           }
         }

    assert_response :unprocessable_entity
    # The rolled-back invoice must come back as a new record, or the form
    # points its PATCH at a row that no longer exists.
    assert_select "form[action=?][method=?]", invoices_path(locale: I18n.locale), "post"
    assert_no_match(/name="_method" value="patch"/, response.body)
  end

  test "cannot issue a draft dated before the last invoice in its series" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number
    @draft.update!(date: 2.years.ago)

    post issue_invoice_url(@draft)

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_match I18n.t('invoice.backdated'), flash[:alert]
    assert_equal original_last, sequence.reload.last_number
    assert_equal 'borrador', @draft.reload.status
    assert_nil @draft.number
  end

  test "cannot destroy a line item of an issued invoice through the invoice form" do
    line_item = @invoice.line_items.first

    patch invoice_url(@invoice),
          params: {
            invoice: {
              notes: 'tampering',
              line_items_attributes: { '0' => { id: line_item.id, _destroy: '1' } }
            }
          }

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_match I18n.t('invoice.update_blocked'), flash[:alert]
    assert LineItem.exists?(line_item.id)
  end

  test "should show invoice" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@draft)
    assert_response :success
  end

  test "should not get edit for an issued invoice" do
    get edit_invoice_url(@invoice)

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_match I18n.t('invoice.update_blocked'), flash[:alert]
  end

  test "should update invoice" do
    patch invoice_url(@draft),
          params: {
            invoice: {
              date: @draft.date,
              due_date: @draft.due_date,
              irpf: @draft.irpf,
              iva: @draft.iva,
              notes: @draft.notes,
              status: @draft.status,
              subtotal: @draft.subtotal,
              total: @draft.total,
              client_id: Client.first.id
            }
          }
    assert_redirected_to invoices_url(locale: I18n.locale)
  end

  test "should not update an issued invoice" do
    patch invoice_url(@invoice), params: { invoice: { total: 99_999 } }

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_match I18n.t('invoice.update_blocked'), flash[:alert]
    assert_equal 121.0, @invoice.reload.total
  end

  test "should destroy draft invoice" do
    assert_difference("Invoice.count", -1) do
      delete invoice_url(@draft)
    end

    assert_redirected_to invoices_url(locale: I18n.locale)
  end

  test "should not destroy issued invoice" do
    assert_no_difference("Invoice.count") do
      delete invoice_url(@invoice)
    end

    assert_redirected_to invoices_url(locale: I18n.locale)
    assert_match I18n.t('invoice.destroy_blocked'), flash[:alert]
  end

  test "should issue a draft invoice" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    post issue_invoice_url(@draft)

    assert_redirected_to invoices_url(locale: I18n.locale)
    @draft.reload
    assert_equal 'pendiente', @draft.status
    assert_equal original_last + 1, @draft.number
    assert_equal invoice_series(:default_a), @draft.series
  end

  test "two sequential issues produce n, n+1" do
    sequence = invoice_sequences(:default_a_active)
    original_last = sequence.last_number

    # Create first draft
    post invoices_url,
         params: {
           save_draft: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             subtotal: 100,
             iva: 21,
             total: 121,
             client_id: clients(:one).id
           }
         }
    first_draft = Invoice.last

    # Create second draft
    post invoices_url,
         params: {
           save_draft: true,
           invoice: {
             date: Date.today,
             due_date: Date.today + 30,
             subtotal: 200,
             iva: 42,
             total: 242,
             client_id: clients(:one).id
           }
         }
    second_draft = Invoice.last

    # Issue first
    post issue_invoice_url(first_draft)
    first_draft.reload
    assert_equal original_last + 1, first_draft.number

    # Issue second
    post issue_invoice_url(second_draft)
    second_draft.reload
    assert_equal original_last + 2, second_draft.number
  end
end
