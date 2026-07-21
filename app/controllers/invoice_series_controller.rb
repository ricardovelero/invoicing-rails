# frozen_string_literal: true

# CRUD for user-owned invoice Scopes (series) and manual Rollover.
class InvoiceSeriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_series, only: [:rollover]

  # GET /invoice_series
  def index
    @series = current_user.invoice_series
                          .includes(:invoice_sequences)
                          .order(:prefix)
  end

  # GET /invoice_series/new
  def new
    @series = current_user.invoice_series.build
  end

  # POST /invoice_series
  def create
    @series = current_user.invoice_series.build(series_params)

    if @series.save
      # Ensure the new scope gets an initial active Sequence automatically
      @series.active_sequence
      redirect_to invoice_series_index_path, notice: I18n.t('scope_created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /invoice_series/:id/rollover
  def rollover
    @series.rollover!
    redirect_to invoice_series_index_path, notice: I18n.t('rollover_success')
  rescue StandardError => e
    redirect_to invoice_series_index_path, alert: I18n.t('rollover_failed', error: e.message)
  end

  private

  def set_series
    @series = current_user.invoice_series.find(params[:id])
  end

  def series_params
    params.require(:invoice_series).permit(:prefix, :name)
  end
end
