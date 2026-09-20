# frozen_string_literal: true

# CRUD for user-owned invoice series.
class InvoiceSeriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_series, only: %i[edit update]

  # GET /invoice_series
  def index
    @series = current_user.invoice_series
                          .includes(:invoice_sequences)
                          .order(:prefix)
    # Precompute invoice counts to avoid N+1
    @invoice_counts = Invoice.where(series_id: @series.pluck(:id))
                             .where.not(number: nil)
                             .group(:series_id)
                             .count
  end

  # GET /invoice_series/new
  def new
    @series = current_user.invoice_series.build
  end

  # POST /invoice_series
  def create
    @series = current_user.invoice_series.build(series_params)

    if @series.save
      # Ensure the new series gets its counter straight away
      @series.sequence
      redirect_to invoice_series_index_path, notice: I18n.t('serie_creada')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /invoice_series/1/edit
  def edit; end

  # PATCH/PUT /invoice_series/1
  def update
    if @series.update(series_params)
      redirect_to invoice_series_index_path, notice: I18n.t('serie_actualizada')
    else
      # The field is about to re-render readonly, but readonly fields are
      # still submitted -- left at the rejected attempted value, every retry
      # (even a name-only one) would resubmit and fail the same way forever.
      @series.prefix = @series.prefix_was if @series.prefix_locked?
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_series
    @series = current_user.invoice_series.find(params[:id])
  end

  def series_params
    params.require(:invoice_series).permit(:prefix, :name)
  end
end
