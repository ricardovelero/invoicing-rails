# frozen_string_literal: true

RSpec.describe 'Framework compatibility', type: :model do # rubocop:disable Metrics/BlockLength
  it 'decodes PostgreSQL dates as dates with Rails 8 defaults' do
    date = ActiveRecord::Base.connection.select_value("SELECT '2026-09-15'::date")

    expect(date).to eq(Date.new(2026, 9, 15))
  end

  it 'preserves Madrid instants and daylight-saving rules when converting to Time' do
    Time.use_zone('Madrid') do
      winter = Time.zone.local(2026, 1, 15, 12)
      summer = Time.zone.local(2026, 7, 15, 12)

      [winter, summer].each do |date|
        expect(date.to_time.to_i).to eq(date.to_i)
        expect(date.to_time.utc_offset).to eq(date.utc_offset)
      end

      expect(winter.to_time.zone).to eq(Time.zone)
      expect(winter.to_time.utc_offset).to eq(3600)
      expect(summer.to_time.utc_offset).to eq(7200)
    end
  end

  it 'rolls back an issued number with its enclosing transaction' do
    draft = invoices(:draft_one)
    sequence = invoice_sequences(:default_a_active)
    original_number = sequence.last_number

    Invoice.transaction(requires_new: true) do
      draft.issue!
      raise ActiveRecord::Rollback
    end

    expect(draft.reload).to be_draft
    expect(draft.number).to be_nil
    expect(sequence.reload.last_number).to eq(original_number)
  end

  it 'delivers mail through the test adapter' do
    expect { TestMailer.hello.deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(ActionMailer::Base.deliveries.last.subject).to eq('Hello from Postmark')
  ensure
    ActionMailer::Base.deliveries.clear
  end
end
