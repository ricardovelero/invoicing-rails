# frozen_string_literal: true

require 'test_helper'

class InvoiceSeriesTest < ActiveSupport::TestCase
  test 'prefix must be present' do
    series = InvoiceSeries.new(user: users(:first), prefix: nil)
    assert_not series.valid?
    assert series.errors[:prefix].any?
  end

  test 'prefix must be unique per user' do
    # default_a fixture already has prefix 'A' for user first
    duplicate = InvoiceSeries.new(user: users(:first), prefix: 'A')
    assert_not duplicate.valid?
    assert duplicate.errors[:prefix].any?
  end

  test 'different users can have same prefix' do
    # user first has prefix 'A' from fixture; user second can also have 'A'
    series = InvoiceSeries.new(user: users(:second), prefix: 'A')
    assert series.valid?
  end

  test 'prefix must be alphanumeric' do
    series = InvoiceSeries.new(user: users(:first), prefix: 'A-B')
    assert_not series.valid?
    assert series.errors[:prefix].any?
  end

  test 'sequence creates lazily if none exists' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')
    assert_equal 0, series.invoice_sequences.count

    sequence = series.sequence
    assert sequence.persisted?
    assert_equal 0, sequence.last_number
  end

  test 'sequence returns the existing counter' do
    series = invoice_series(:default_a)
    assert_equal series.invoice_sequences.first, series.sequence
  end

  test 'a series can never hold a second counter' do
    series = invoice_series(:default_a)

    assert_raises(ActiveRecord::RecordNotUnique) do
      InvoiceSequence.create!(invoice_series: series, last_number: 0)
    end
  end

  test 'a series that has issued invoices cannot restart its numbering' do
    # The rollover this replaces: retire the counter, get a fresh one at zero,
    # and hand out A-0001 again after A-0102. Art. 6.1.a RD 1619/2012 forbids it.
    series = invoice_series(:default_a)
    counter = series.sequence

    assert_equal counter, series.reload.sequence
    assert_equal 102, series.sequence.last_number
    assert_equal 1, series.invoice_sequences.count
  end

  test 'cannot destroy a series that has invoices' do
    series = invoice_series(:default_a)

    assert_not series.destroy
    assert series.persisted?
    assert_equal invoice_series(:default_a), invoices(:one).reload.series
  end

  test 'can destroy a series with no invoices' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')
    series.sequence

    assert series.destroy
    assert series.destroyed?
  end

  test 'sequence recovers when another process wins the race' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'D')
    winner = InvoiceSequence.create!(invoice_series: series, last_number: 7)

    # Stand in for the caller whose read happened before the winner committed:
    # it saw no counter and tries to create one. Inside a transaction, as Issue
    # is -- the unique violation must not take that transaction down with it.
    Invoice.transaction do
      assert_equal winner, series.send(:create_sequence)
      assert_equal 1, series.invoice_sequences.count
    end
  end

  test 'display_name returns prefix when no name' do
    series = invoice_series(:default_a)
    assert_equal 'A', series.display_name
  end

  test 'display_name returns prefix and name when name present' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'R', name: 'Rectifying')
    assert_equal 'R — Rectifying', series.display_name
  end

  test 'prefix cannot change once the series has issued invoices' do
    series = invoice_series(:default_a)

    assert_not series.update(prefix: 'Z')
    assert series.errors[:prefix].any?
    assert_equal 'A', series.reload.prefix
  end

  test 'name can still change once the series has issued invoices' do
    series = invoice_series(:default_a)

    assert series.update(name: 'Ordinary invoices')
  end

  test 'prefix cannot change once the series has a numbered draft invoice' do
    # assign_number! is public and never itself flips status: a draft can
    # hold a Number (and thus a live display_number) without being "issued".
    series = InvoiceSeries.create!(user: users(:first), prefix: 'D')
    invoice = Invoice.create!(user: users(:first), client: clients(:one), date: Date.today,
                              due_date: Date.today + 30, status: 'borrador',
                              subtotal: 100, iva: 21, total: 121)
    Invoice.transaction { invoice.assign_number!(series) }
    assert_equal 'borrador', invoice.reload.status

    assert_not series.update(prefix: 'E')
    assert series.errors[:prefix].any?
    assert_equal 'D', series.reload.prefix
  end

  test 'prefix can change on a series with no issued invoices' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')

    assert series.update(prefix: 'C')
  end
end
