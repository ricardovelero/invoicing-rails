# frozen_string_literal: true

RSpec.describe 'Rails upgrade compatibility', type: :request do # rubocop:disable Metrics/BlockLength
  it 'keeps authenticated pages protected' do
    get invoices_path(locale: :es)

    expect(response).to redirect_to(new_user_session_path)
  end

  it 'authenticates with Devise and retains the session on subsequent requests' do
    post user_session_path(locale: :es), params: {
      user: { email: users(:first).email, password: 'password' }
    }

    expect(response).to redirect_to('/dashboard?locale=es')

    get invoices_path(locale: :es)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(invoices(:one).display_number)
  end

  it 'preserves the invoice JSON representation through Jbuilder' do
    sign_in users(:first)
    invoice = invoices(:one)

    get invoice_path(invoice, locale: :es, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      'id' => invoice.id,
      'number' => 'A-0100',
      'status' => 'pendiente',
      'date' => invoice.date.iso8601(3),
      'due_date' => invoice.due_date.iso8601(3)
    )
  end

  it 'renders an existing invoice as a PDF' do
    sign_in users(:first)

    get invoice_path(invoices(:one), locale: :es, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/pdf')
    expect(response.body).to start_with('%PDF-')
  end

  it 'rejects invalid JSON invoice creation without creating a record' do
    sign_in users(:first)

    expect do
      post invoices_path(locale: :es, format: :json), params: {
        save_and_issue: true, invoice: { client_id: clients(:one).id }
      }
    end.not_to change(Invoice, :count)

    expect(response).to have_http_status(422)
    expect(response.parsed_body).to include('date', 'due_date')
  end

  it 'keeps invoice creation and numbering atomic on a rejected issue' do
    sign_in users(:first)
    sequence = invoice_sequences(:default_a_active)
    original_number = sequence.last_number

    expect do
      post invoices_path(locale: :es, format: :json), params: {
        save_and_issue: true,
        invoice: { client_id: clients(:one).id, date: 2.years.ago.to_date, due_date: Date.current }
      }
    end.not_to change(Invoice, :count)

    expect(response).to have_http_status(422)
    expect(sequence.reload.last_number).to eq(original_number)
  end

  it 'issues a draft using the next number and renders the updated JSON' do
    sign_in users(:first)
    draft = invoices(:draft_one)

    post issue_invoice_path(draft, locale: :es, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include('number' => 'A-0103', 'status' => 'pendiente')
    expect(draft.reload.number).to eq(103)
    expect(invoice_sequences(:default_a_active).reload.last_number).to eq(103)
  end

  it 'renders Turbo Stream line-item fields with the existing target' do
    sign_in users(:first)

    post add_item_invoices_path(locale: :es), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    expect(response.body).to include('<turbo-stream action="append" target="line_items">')
    expect(response.body).to include('invoice[line_items_attributes]')
  end

  it 'honors the selected language on authenticated pages' do
    sign_in users(:first)

    %i[es en].each do |locale|
      get new_invoice_path(locale:)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('nueva_factura', locale:))
    end
  end
end
