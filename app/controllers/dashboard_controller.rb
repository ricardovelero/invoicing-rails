class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    report_data = Charts::InvoicesChart.new(current_user).generate

    @categories = report_data.keys.to_json
    @series = report_data.values.to_json
  end
end
