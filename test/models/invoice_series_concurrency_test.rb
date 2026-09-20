# frozen_string_literal: true

require 'test_helper'

# Regression test for the lock in InvoiceSeries#prefix_immutable_once_issued:
# a prefix rename and a concurrent first Issue must serialize on the same
# sequence row instead of racing.
#
# Proving that needs two genuinely overlapping, uncommitted transactions on
# separate connections -- something transactional fixtures (single
# connection, rolled back per test) cannot produce. Hence
# use_transactional_tests = false, kept in its own file so the rest of the
# suite keeps the fast, transactional default.
class InvoiceSeriesConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  def teardown
    # Unstick the issuer first, unconditionally: if an earlier assertion
    # raised before the test released it, it is still parked on
    # release_issuer.pop holding the sequence row lock, and the deletes
    # below would hang against it forever instead of failing the test.
    @release_issuer&.push(true)
    safe_join(@issuer)
    safe_join(@renamer)

    return unless @series

    Invoice.where(series_id: @series.id).delete_all
    InvoiceSequence.where(invoice_series_id: @series.id).delete_all
    @series.delete
  end

  test 'a prefix rename blocks on a concurrent first Issue, then loses once it commits' do
    @series = InvoiceSeries.create!(user: users(:first), prefix: 'Q')
    @series.sequence # provision the counter row before either side races for it

    holding_lock = Queue.new
    @release_issuer = Queue.new
    result = { issued_invoice: nil, rename_succeeded: nil, renamer_pid: nil }

    @issuer = start_issuer(holding_lock, result)
    holding_lock.pop # don't start the rename until the issuer genuinely holds the lock

    @renamer = start_renamer(result)

    assert wait_for_lock_wait(-> { result[:renamer_pid] }),
           'expected the rename to block waiting for the sequence row lock'
    assert @renamer.alive?, 'rename should still be blocked, not finished'

    @release_issuer << true
    safe_join(@issuer)
    safe_join(@renamer)

    assert result[:issued_invoice].persisted?
    assert_not result[:rename_succeeded], 'rename should be rejected: the series now has an issued invoice'
    assert_equal 'Q', @series.reload.prefix
  end

  private

  # Locks the sequence row itself first so we control exactly when the
  # renamer gets to observe it -- reserve_next! takes the identical lock,
  # but has no pause point to signal from mid-method.
  def start_issuer(holding_lock, result)
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Invoice.transaction do
          InvoiceSeries.find(@series.id).sequence.lock!
          holding_lock << true
          @release_issuer.pop

          result[:issued_invoice] = build_draft_invoice.tap(&:issue!)
        end
      end
    end
  end

  def build_draft_invoice
    users(:first).invoices.new(series: @series, client: clients(:one), date: Date.current,
                               due_date: 1.day.from_now, subtotal: 10, iva: 0, irpf: 0, total: 10)
  end

  def start_renamer(result)
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        result[:renamer_pid] = ActiveRecord::Base.connection.raw_connection.backend_pid
        result[:rename_succeeded] = InvoiceSeries.find(@series.id).update(prefix: 'R')
      end
    end
  end

  # Polls pg_stat_activity instead of sleeping a fixed amount: confirms the
  # renamer's backend is actually parked on a lock wait, not just "probably
  # scheduled by now".
  def wait_for_lock_wait(pid_proc, timeout: 5)
    deadline = Time.now + timeout
    until Time.now >= deadline
      return true if pid_proc.call && lock_wait?(pid_proc.call)

      sleep 0.02
    end
    false
  end

  def lock_wait?(pid)
    ActiveRecord::Base.connection.select_value(
      "SELECT wait_event_type FROM pg_stat_activity WHERE pid = #{pid.to_i}"
    ) == 'Lock'
  end

  # Bounded join that swallows a re-raised thread exception -- teardown must
  # never itself hang or blow up and hide the test's real failure.
  def safe_join(thread)
    return unless thread

    thread.join(5)
  rescue StandardError => e
    warn "InvoiceSeriesConcurrencyTest: background thread raised during join: #{e.message}"
  end
end
