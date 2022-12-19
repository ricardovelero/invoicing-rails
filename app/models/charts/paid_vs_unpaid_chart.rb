class Charts::PaidVsUnpaidChart
  def initialize(user_id)
    @user_id = user_id
  end

  def generate
    query_data
  end

  private

  def query_data
    Invoice
      .for_account(@user_id)
      .group('status')
      .count
  end
end