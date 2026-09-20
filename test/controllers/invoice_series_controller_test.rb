# frozen_string_literal: true

require 'test_helper'

class InvoiceSeriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:first)
  end

  test 'should get index' do
    get invoice_series_index_url
    assert_response :success
  end

  test 'index edit link is accessibly labeled as editing a series' do
    get invoice_series_index_url
    assert_select "a[href^=?]", edit_invoice_series_path(invoice_series(:default_a)) do
      assert_select '.sr-only', text: I18n.t('editar_serie')
    end
  end

  test 'should get new' do
    get new_invoice_series_url
    assert_response :success
  end

  test 'should create series with prefix only' do
    assert_difference('InvoiceSeries.count') do
      post invoice_series_index_url, params: { invoice_series: { prefix: 'B' } }
    end

    series = InvoiceSeries.last
    assert_equal 'B', series.prefix
    assert_equal users(:first), series.user
    # Should have an initial active sequence
    assert series.invoice_sequences.first.present?
    assert_redirected_to invoice_series_index_url(locale: I18n.locale)
  end

  test 'should create series with prefix and name' do
    assert_difference('InvoiceSeries.count') do
      post invoice_series_index_url, params: { invoice_series: { prefix: 'R', name: 'Rectifying' } }
    end

    series = InvoiceSeries.last
    assert_equal 'R', series.prefix
    assert_equal 'Rectifying', series.name
    assert_redirected_to invoice_series_index_url(locale: I18n.locale)
  end

  test 'rejects duplicate prefix within same account' do
    # 'A' already exists for user first (from fixture)
    assert_no_difference('InvoiceSeries.count') do
      post invoice_series_index_url, params: { invoice_series: { prefix: 'A' } }
    end

    assert_response :unprocessable_entity
  end

  test 'allows same prefix for different user' do
    sign_in users(:second)
    assert_difference('InvoiceSeries.count') do
      post invoice_series_index_url, params: { invoice_series: { prefix: 'A' } }
    end
    assert_redirected_to invoice_series_index_url(locale: I18n.locale)
  end

  test 'rejects non-alphanumeric prefix' do
    assert_no_difference('InvoiceSeries.count') do
      post invoice_series_index_url, params: { invoice_series: { prefix: 'A-B' } }
    end
    assert_response :unprocessable_entity
  end

  test "user cannot see another user's series on index" do
    sign_in users(:second)
    get invoice_series_index_url
    assert_response :success
    # The page should show the empty state for user second (no series)
    assert_match I18n.t('no_hay_series'), response.body
  end

  test 'should get edit' do
    get edit_invoice_series_url(invoice_series(:default_a))
    assert_response :success
  end

  test 'should update name on a series with issued invoices' do
    series = invoice_series(:default_a)
    patch invoice_series_url(series), params: { invoice_series: { name: 'Facturas ordinarias' } }

    assert_redirected_to invoice_series_index_url(locale: I18n.locale)
    assert_equal 'Facturas ordinarias', series.reload.name
  end

  test 'rejects prefix change once the series has issued invoices' do
    series = invoice_series(:default_a)
    patch invoice_series_url(series), params: { invoice_series: { prefix: 'Z' } }

    assert_response :unprocessable_entity
    assert_equal 'A', series.reload.prefix
  end

  test 'allows prefix change on a series with no issued invoices' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')
    patch invoice_series_url(series), params: { invoice_series: { prefix: 'C' } }

    assert_redirected_to invoice_series_index_url(locale: I18n.locale)
    assert_equal 'C', series.reload.prefix
  end

  test 'retains the persisted prefix, not the rejected attempt, when a rename is rejected' do
    # Simulate the race: the edit page was opened while the series was still
    # unused, but an invoice got numbered on it before the rename submitted.
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')
    invoice = Invoice.create!(user: users(:first), client: clients(:one), date: Date.today,
                              due_date: Date.today + 30, status: 'borrador',
                              subtotal: 100, iva: 21, total: 121)
    Invoice.transaction { invoice.assign_number!(series) }

    patch invoice_series_url(series), params: { invoice_series: { prefix: 'Z' } }

    assert_response :unprocessable_entity
    assert_equal 'B', series.reload.prefix
    # The re-rendered field must show the real, persisted prefix: it is about
    # to go readonly, and a readonly field still submits its value -- left at
    # the rejected 'Z', every retry (even a name-only one) would resubmit and
    # fail the same way forever.
    assert_select "input[name='invoice_series[prefix]'][value=?][readonly]", 'B'
  end

  test "user cannot edit another user's series" do
    sign_in users(:second)
    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_invoice_series_url(invoice_series(:default_a))
    end
  end
end
