require "test_helper"

class InvoiceSequenceTest < ActiveSupport::TestCase
  test "reserve_next! increments last_number atomically" do
    sequence = invoice_sequences(:default_a_active)
    original_number = sequence.last_number

    Invoice.transaction do
      next_number = sequence.reserve_next!
      assert_equal original_number + 1, next_number
    end

    sequence.reload
    assert_equal original_number + 1, sequence.last_number
  end

  test "reserve_next! raises if sequence is not active" do
    sequence = invoice_sequences(:default_a_active)
    sequence.update_column(:active, false)

    assert_raises(RuntimeError, 'Sequence is not active') do
      sequence.reserve_next!
    end
  end

  test "exactly one active sequence per series enforced by DB" do
    series = invoice_series(:default_a)
    # There's already one active sequence from fixtures
    second = InvoiceSequence.new(invoice_series: series, active: true, last_number: 0)

    assert_raises(ActiveRecord::RecordNotUnique) do
      second.save!
    end
  end

  test "failed transaction rolls back counter (no burned numbers)" do
    sequence = invoice_sequences(:default_a_active)
    original_number = sequence.last_number

    begin
      Invoice.transaction do
        sequence.reserve_next!
        raise ActiveRecord::Rollback
      end
    rescue
      # no-op
    end

    sequence.reload
    # The counter should still be at original because the transaction rolled back
    assert_equal original_number, sequence.last_number
  end
end
