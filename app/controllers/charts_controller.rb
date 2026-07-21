class ChartsController < ApplicationController
  ALLOWED_CHARTS = %w[Charts::InvoicesChart Charts::PaidVsUnpaidChart].freeze

  before_action :authenticate_user!
  before_action :set_chart

  def show
    report_data = @chart.constantize.new(current_user).generate
    @labels = report_data.keys.to_json
    @series = report_data.values.to_json
    @chart_partial = chart_to_partial
  end

  private

  def set_chart
    raise ActiveRecord::RecordNotFound unless ALLOWED_CHARTS.include?(params[:chart_type])

    @chart = params[:chart_type]
  end

  def chart_to_partial
    @chart.gsub('Charts::', '').underscore
  end
end