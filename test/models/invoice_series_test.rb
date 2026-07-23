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

  test 'active_sequence creates lazily if none exists' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'B')
    assert_nil series.invoice_sequences.find_by(active: true)
    sequence = series.active_sequence
    assert sequence.persisted?
    assert sequence.active?
    assert_equal 0, sequence.last_number
  end

  test 'active_sequence returns existing active sequence' do
    series = invoice_series(:default_a)
    existing = series.invoice_sequences.find_by(active: true)
    assert_equal existing, series.active_sequence
  end

  test 'new scope gets initial active sequence automatically via active_sequence' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'C')
    # No sequence exists yet
    assert_equal 0, series.invoice_sequences.count

    # Calling active_sequence creates one
    seq = series.active_sequence
    assert seq.persisted?
    assert seq.active?
    assert_equal 0, seq.last_number
  end

  test 'display_name returns prefix when no name' do
    series = invoice_series(:default_a)
    assert_equal 'A', series.display_name
  end

  test 'display_name returns prefix and name when name present' do
    series = InvoiceSeries.create!(user: users(:first), prefix: 'R', name: 'Rectifying')
    assert_equal 'R — Rectifying', series.display_name
  end
end
