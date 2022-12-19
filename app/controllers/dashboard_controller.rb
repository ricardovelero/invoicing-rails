class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    report_data = Charts::InvoicesChart.new(current_user).generate
    @categories = report_data.keys.to_json
    @series = report_data.values.to_json

    pvsu_data = Charts::PaidVsUnpaidChart.new(current_user).generate
    @pvsu_labels = pvsu_data.keys.map(&:humanize).to_json
    @pvsu_series = pvsu_data.values.to_json
  end
end
