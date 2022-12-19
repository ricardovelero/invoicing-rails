class Charts::InvoicesChart
  def initialize(user_id)
    @user_id = user_id
  end

  def generate
    invoices = query_data
    zero_fill_dates(invoices)
  end

  private

  def query_data
    Invoice
      .for_account(@user_id)
      .where('invoices.date > ?', 90.days.ago)
      .group('date(invoices.date)')
      .count
  end

  def zero_fill_dates(invoices)
    (90.days.ago.to_date..Date.today.to_date).each_with_object({}) do |date, hash|
      hash[date] = invoices.fetch(date, 0)
    end
  end
end