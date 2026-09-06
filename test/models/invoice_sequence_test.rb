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

  test "reserve_next! increments by exactly one from a stale record" do
    sequence = invoice_sequences(:default_a_active)
    stale = InvoiceSequence.find(sequence.id)

    # A concurrent request reserves two numbers and commits before `stale`
    # reaches the lock, leaving its in-memory attributes behind the row.
    InvoiceSequence.update_counters(sequence.id, last_number: 2)
    last_number = sequence.reload.last_number

    reserved = nil
    Invoice.transaction { reserved = stale.reserve_next! }

    assert_equal last_number + 1, reserved
    assert_equal reserved, sequence.reload.last_number
  end

  test "exactly one sequence per series enforced by DB" do
    series = invoice_series(:default_a)
    second = InvoiceSequence.new(invoice_series: series, last_number: 0)

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
